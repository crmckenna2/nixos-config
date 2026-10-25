#!/usr/bin/env python3
"""
Nix & Direnv MCP Server for OpenCode on NixOS.
Provides package discovery via nix-index/nix-search, ephemeral execution,
and declarative flake.nix + direnv devshell management.
"""

import json
import os
import subprocess
from pathlib import Path
from typing import Optional
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("nix-manager")


def run_cmd(
    cmd: list[str], cwd: Optional[str] = None, timeout: int = 120
) -> dict[str, str | int]:
    """Run a subprocess safely and return structured output."""
    env = os.environ.copy()
    # Ensure nix flakes and nix-command are always enabled for the llm user
    env["NIX_CONFIG"] = (
        env.get("NIX_CONFIG", "")
        + "\nexperimental-features = nix-command flakes\n"
    )
    try:
        res = subprocess.run(
            cmd,
            cwd=cwd,
            env=env,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        return {
            "returncode": res.returncode,
            "stdout": res.stdout.strip(),
            "stderr": res.stderr.strip(),
        }
    except subprocess.TimeoutExpired:
        return {
            "returncode": -1,
            "stdout": "",
            "stderr": f"Command timed out after {timeout}s: {' '.join(cmd)}",
        }
    except Exception as e:
        return {"returncode": -1, "stdout": "", "stderr": str(e)}


@mcp.tool()
def nix_locate_file(
    pattern: str,
    bin_only: bool = True,
    whole_name: bool = True,
    limit: int = 25,
) -> str:
    """
    Find which nixpkgs attribute provides a specific binary, header (.h), or shared library (.so)
    using nix-index (`nix-locate`).

    Args:
        pattern: File or binary name to find (e.g., "cargo", "libssl.so", "zlib.h").
        bin_only: If True, searches strictly for `/bin/<pattern>` at the package root.
        whole_name: Match the exact filename instead of a substring.
        limit: Maximum number of package candidates to return.
    """
    cmd = ["nix-locate", "--minimal", "--top-level"]
    if whole_name:
        cmd.append("--whole-name")

    if bin_only:
        clean = pattern.lstrip("/")
        if not clean.startswith("bin/"):
            clean = f"/bin/{clean}"
        else:
            clean = f"/{clean}"
        cmd.extend(["--at-root", clean])
    else:
        cmd.append(pattern)

    res = run_cmd(cmd, timeout=30)
    if res["returncode"] != 0 and not res["stdout"]:
        return (
            f"nix-locate failed (is nix-index database built via `nix-index`?):\n"
            f"{res['stderr']}"
        )

    lines = [line for line in str(res["stdout"]).splitlines() if line.strip()]
    if not lines:
        return f"No packages found matching '{pattern}'."

    selected = lines[:limit]
    return (
        f"Found {len(lines)} matching package output(s) (showing top {len(selected)}):\n"
        + "\n".join(f"- {pkg}" for pkg in selected)
        + "\n\nTip: Strip the output suffix (e.g., `.out` or `.bin`) when adding to `flake.nix` packages."
    )


@mcp.tool()
def nix_search_packages(query: str, flake: str = "nixpkgs", limit: int = 15) -> str:
    """
    Search nixpkgs by package name or description using `nix search --json`.

    Args:
        query: Search term or regex (e.g., "ripgrep", "postgresql", "python3Packages.fastapi").
        flake: Flake registry name or URI (default: "nixpkgs").
        limit: Max results to return.
    """
    res = run_cmd(["nix", "search", flake, query, "--json"], timeout=60)
    if res["returncode"] != 0:
        return f"Error running nix search:\n{res['stderr']}"

    if not res["stdout"]:
        return f"No packages found matching '{query}'."

    try:
        data = json.loads(str(res["stdout"]))
    except json.JSONDecodeError:
        return f"Failed to parse nix search output:\n{res['stdout']}"

    results = []
    for full_attr, info in list(data.items())[:limit]:
        # Strip legacyPackages.<system>. prefix for clean flake usage
        parts = full_attr.split(".")
        short_attr = ".".join(parts[2:]) if len(parts) > 2 else full_attr
        version = info.get("version", "unknown")
        desc = info.get("description", "No description")
        results.append(f"- **{short_attr}** (v{version}): {desc}")

    return f"Search results for '{query}' ({len(results)} shown):\n" + "\n".join(results)


@mcp.tool()
def nix_ephemeral_run(
    packages: list[str],
    command: str,
    cwd: str = ".",
    impure: bool = False,
) -> str:
    """
    Run a one-off command inside an ephemeral Nix shell with specified packages WITHOUT
    modifying project files. Great for running formatters, linters, generators, or CLI tools.

    Args:
        packages: List of nixpkgs attributes (e.g., ["jq", "ripgrep", "python312Packages.httpie"]).
        command: Bash command string to execute inside the ephemeral environment.
        cwd: Working directory for execution.
        impure: Allow impure environment variables if needed.
    """
    flake_refs = [
        pkg if "#" in pkg else f"nixpkgs#{pkg}" for pkg in packages
    ]
    cmd = ["nix", "shell"]
    if impure:
        cmd.append("--impure")
    cmd.extend(flake_refs)
    cmd.extend(["--command", "bash", "-c", command])

    res = run_cmd(cmd, cwd=cwd, timeout=300)
    return (
        f"Exit Code: {res['returncode']}\n"
        f"--- STDOUT ---\n{res['stdout']}\n"
        f"--- STDERR ---\n{res['stderr']}"
    )


@mcp.tool()
def nix_devshell_init(
    project_dir: str,
    packages: list[str],
    shell_hook: str = "",
    ld_library_packages: Optional[list[str]] = None,
) -> str:
    """
    Initialize or update a declarative `flake.nix` devShell and `.envrc` in `project_dir`,
    stage `flake.nix` in Git (required so Nix Flakes can see it), and run `direnv allow`.

    Args:
        project_dir: Path to the project root directory.
        packages: Nixpkgs attribute names to include in `packages` (e.g., ["nodejs_22", "pnpm", "jq"]).
        shell_hook: Optional bash snippet to run when entering the devShell.
        ld_library_packages: Optional list of packages to expose in LD_LIBRARY_PATH (useful for
                             Python wheels / precompiled binaries needing zlib, stdenv.cc.cc.lib, openssl, etc.).
    """
    target = Path(project_dir).resolve()
    target.mkdir(parents=True, exist_ok=True)

    pkg_list_str = "\n            ".join(packages)
    ld_list = ld_library_packages or []
    ld_block = ""
    if ld_list:
        ld_joined = " ".join(ld_list)
        ld_block = f"""
          env.LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs; [ {ld_joined} ]);"""

    flake_content = f"""{{
  description = "Declarative development environment managed by OpenCode";

  inputs = {{
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  }};

  outputs = {{ self, nixpkgs }}:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {{
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs {{ inherit system; }};
        in
        {{
          default = pkgs.mkShell {{
            packages = with pkgs; [
              {pkg_list_str}
            ];{ld_block}
            shellHook = ''
              {shell_hook}
            '';
          }};
        }});
    }};
}}
"""
    flake_path = target / "flake.nix"
    flake_path.write_text(flake_content)

    # Ensure .envrc has `use flake`
    envrc_path = target / ".envrc"
    if not envrc_path.exists() or "use flake" not in envrc_path.read_text():
        existing = envrc_path.read_text() + "\n" if envrc_path.exists() else ""
        envrc_path.write_text(f"use flake\n{existing}")

    # Crucial Nix Flakes rule: if inside a git repo, untracked flake.nix files are invisible to Nix!
    git_check = run_cmd(["git", "rev-parse", "--is-inside-work-tree"], cwd=str(target))
    if git_check["returncode"] == 0:
        run_cmd(["git", "add", "--intent-to-add", "flake.nix"], cwd=str(target))

    # Authorize direnv and verify the devshell builds
    direnv_res = run_cmd(["direnv", "allow"], cwd=str(target))
    verify_res = run_cmd(
        ["nix", "develop", "path:.", "--command", "true"],
        cwd=str(target),
        timeout=300,
    )

    status = "SUCCESS" if verify_res["returncode"] == 0 else "ERROR"
    return (
        f"[{status}] Wrote flake.nix and .envrc in {target}\n"
        f"direnv allow: {direnv_res['stderr'] or 'OK'}\n"
        f"devShell build check (exit {verify_res['returncode']}):\n{verify_res['stderr']}"
    )


@mcp.tool()
def nix_devshell_exec(command: str, project_dir: str = ".") -> str:
    """
    Execute a shell command inside the project's active Nix devShell.
    Uses `direnv exec` first (fast cached environment) and falls back to `nix develop path:.`.

    Args:
        command: Bash command to execute inside the devShell.
        project_dir: Directory containing `.envrc` / `flake.nix`.
    """
    target = str(Path(project_dir).resolve())
    envrc = Path(target) / ".envrc"

    if envrc.exists():
        run_cmd(["direnv", "allow"], cwd=target, timeout=15)
        res = run_cmd(["direnv", "exec", target, "bash", "-c", command], cwd=target, timeout=300)
        if res["returncode"] == 0 or "direnv: error" not in str(res["stderr"]):
            return (
                f"Executed via direnv (Exit Code {res['returncode']}):\n"
                f"--- STDOUT ---\n{res['stdout']}\n"
                f"--- STDERR ---\n{res['stderr']}"
            )

    # Fallback to `nix develop path:.` (path:. bypasses git untracked file restrictions)
    res = run_cmd(
        ["nix", "develop", "path:.", "--command", "bash", "-c", command],
        cwd=target,
        timeout=300,
    )
    return (
        f"Executed via nix develop (Exit Code {res['returncode']}):\n"
        f"--- STDOUT ---\n{res['stdout']}\n"
        f"--- STDERR ---\n{res['stderr']}"
    )


@mcp.tool()
def nix_eval_expr(expr: str) -> str:
    """
    Evaluate a Nix expression against <nixpkgs> and return JSON output.
    Useful for inspecting package versions, available outputs (`dev`, `lib`), or Python subpackages.

    Example expr:
      `let pkgs = import <nixpkgs> {}; in pkgs.openssl.outputs`
      `let pkgs = import <nixpkgs> {}; in builtins.attrNames pkgs.python3Packages`
    """
    res = run_cmd(["nix", "eval", "--impure", "--json", "--expr", expr], timeout=30)
    if res["returncode"] != 0:
        return f"Evaluation error:\n{res['stderr']}"
    return str(res["stdout"])


if __name__ == "__main__":
    mcp.run()

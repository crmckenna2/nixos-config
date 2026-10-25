---
name: nix-workflow
description: Manage packages, missing binaries, C headers, shared libraries, and project environments declaratively on NixOS using flake.nix devShells, direnv, and nix-index. Load this skill whenever a command is missing, a library fails to link, or a project environment needs setup.
license: MIT
compatibility: opencode
---

## Core NixOS Operating Rules for `llm`

You are running on **NixOS** under the dedicated `llm` user. NixOS does not use an FHS global `/usr/bin` or `/usr/lib`.

1. **NEVER attempt imperative package installations:**
   - Do NOT run `apt`, `apk`, `dnf`, `brew`, `nix-env -i`, `nix profile install`, or `sudo`.
   - Do NOT run `pip install` or `npm install -g` globally outside of a project environment.
2. **Choose the right Nix mechanism:**
   - **One-off CLI utility needed temporarily** (e.g., `jq`, `tree`, `gh`, `sqlfluff`): Call `nix_ephemeral_run` or run `nix shell nixpkgs#<pkg> --command ...`.
   - **Project dependency, compiler, SDK, or runtime** (e.g., `cargo`, `nodejs_22`, `python3`, `postgresql`, `pkg-config`, `openssl`): Put it in the project's `flake.nix` `devShells.default` and `.envrc`, then run project commands through `nix_devshell_exec` or `direnv exec . <cmd>`.

---

## Workflow 1: Finding Missing Binaries, Headers, or Libraries

When a build or command fails because a binary, header (`.h`), or shared library (`.so`) is missing:

1. **Find binaries:** Use `nix_locate_file(pattern="cmake", bin_only=True)` (which runs `nix-locate --minimal --top-level --whole-name --at-root /bin/cmake`).
2. **Find C/C++ headers or `.so` libraries:** Use `nix_locate_file(pattern="libssl.so", bin_only=False)` or `nix_locate_file(pattern="zlib.h", bin_only=False)`.
   - **Important:** When `nix-locate` returns an output like `openssl.dev` or `zlib.out`, strip `.out` when adding to `packages = with pkgs; [ ... ];`. For C headers/pkg-config files, include `pkg-config` in `packages` so Nix's setup hook automatically populates `PKG_CONFIG_PATH`.

---

## Workflow 2: Avoiding the Git + Nix Flakes Untracked File Trap

Nix Flakes ignore any file inside a Git repository that is not tracked by Git.
- Whenever you create `flake.nix` (or supplementary Nix files imported by `flake.nix`) in a Git repo, **immediately run**:
  ```bash
  git add --intent-to-add flake.nix

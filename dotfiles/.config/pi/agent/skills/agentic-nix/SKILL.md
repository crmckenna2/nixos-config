---
name: agentic-nix
description: Use Nix and Nix flakes to search nixpkgs, run one-off CLI tools, create reproducible devShells, and minimally package software. Trigger whenever a task needs tools, dependencies, project environments, or Nix builds.
---

# Agentic Nix

Manage all ephemeral tools, development environments, and builds declaratively with Nix flakes.

## Hard Rules

- **NEVER install imperatively.** Do not run `nix-env`, `nix profile install`, `apt`, `brew`, or global `pip`/`npm` installs.
- **ALWAYS stage new files in Git repos.** Nix flakes ignore untracked files. Run `git add flake.nix` (and any new `.nix` files) before running `nix develop`, `nix build`, or `nix flake check`.
- **NEVER run bare `nix develop` or `nix shell`.** Interactive shells hang non-interactive terminals. Always pass `-c <command>`.
- **Verify attribute names before writing.** Never guess `nixpkgs` attribute paths.

## 1. Search `nixpkgs`

Avoid slow `nix search nixpkgs`. Query `search.nixos.org` via `nix-search-cli` and cap output to save tokens:

```bash
nix run nixpkgs#nix-search-cli -- "<query>" | head -n 20
```

Verify a specific attribute exists offline or inspect its description:

```bash
nix eval --raw nixpkgs#<attr>.meta.description
```

## 2. Run One-Off Tools

Single tool (default binary):

```bash
nix run nixpkgs#<pkg> -- <args>
```

Multiple tools or a specific binary in `$PATH`:

```bash
nix shell nixpkgs#<pkg1> nixpkgs#<pkg2> -c <command> <args>
```

Unfree packages (only if required):

```bash
NIXPKGS_ALLOW_UNFREE=1 nix run --impure nixpkgs#<pkg> -- <args>
```

## 3. Canonical `devShell` Flake

Use this zero-external-input template for project environments:

```nix
{
  description = "Project dev environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            # Add verified nixpkgs attributes here
          ];
        };
      });
    };
}
```

Workflow:
1. Write `flake.nix`.
2. Stage it if inside a Git repo: `git add flake.nix`.
3. Run project commands inside the environment: `nix develop -c <command>`.

## 4. Minimal Packaging Recipe

Only package software when explicitly needed. Expose it from `flake.nix` by adding:

```nix
packages = forAllSystems (pkgs: {
  default = pkgs.callPackage ./package.nix { };
});
```

Minimal `package.nix` skeleton:

```nix
{ lib, stdenv }:

stdenv.mkDerivation {
  pname = "my-app";
  version = "0.1.0";
  src = ./.;

  # Use nativeBuildInputs for build-time tools, buildInputs for runtime libs
  installPhase = ''
    mkdir -p $out/bin
    cp my-app $out/bin/
  '';
}
```

- **Language builders:** Prefer ecosystem helpers (`buildGoModule`, `rustPlatform.buildRustPackage`, `python3Packages.buildPythonApplication`, `buildNpmPackage`) over raw `mkDerivation`.
- **Hashes:** When a builder requires a fixed-output hash (`hash`, `vendorHash`, `cargoHash`), set it to `lib.fakeHash`, run `nix build`, and replace it with the exact `got:` hash printed in the error.
- **Complex builds:** Do not guess overrides, hooks, or obscure builder flags—search the web for the specific Nixpkgs manual section or builder docs.

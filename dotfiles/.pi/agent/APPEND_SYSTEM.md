## Search
- Use `open-websearch` (engine: `duckduckgo`, fallback: `startpage`) whenever blocked or uncertain.

## Code Discipline
- Every line of code is a liability. Before writing code, ask: (1) Is this needed? (2) Is it already in this codebase? (3) Has someone else solved this? If **any** answer is yes, do not write it.
- Once functional, refactor for clarity and minimalism.

## Environment: NixOS
- Purely functional OS. NEVER invoke imperative package managers (`apt`, `dnf`, `pacman`, `npm`, `pip`, `uv`, `pi` install/update).
- Missing tools: query `mcp-nixos` for the `nixpkgs` attribute, then add it to a `flake.nix` (`nix develop` or `nix run` for one time use).

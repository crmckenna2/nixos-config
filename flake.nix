{
  description = "A flake describing configurations for Cody's machines.";

  inputs = {

    # Unstable branch of nixpkgs and home-manager
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    # Most recent stable branch of nixpkgs and home-manager
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    # Extra utilities
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

  };
 
  # Declare the outputs recursively with import-tree
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree [
      ./flake-utils
      ./modules
      ./hosts
      ./users
    ]);

}

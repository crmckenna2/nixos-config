{
  description = "A flake describing configurations for Cody's machines.";

  inputs = {

    # Most recent stable branch of nixpkgs and home-manager
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # home-manager.url = "github:nix-community/home-manager/release-26.05";

    # Unstable branch of nixpkgs and home-manager
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";

    # Extra utilities
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

  };
 
  # Declare the outputs recursively with import-tree
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree [
      ./.flake-parts
      ./hosts
      ./users
      ./modules
    ]);

}

{ inputs, ... }: {

  flake.nixosModules.stable-overlay = { config, ... }: {

    nixpkgs.overlays = [
      ( final: prev: {
        stable = import inputs.nixpkgs-stable {
          inherit (prev.stdenv.hostPlatform) system;
          config.allowUnfree = config.nixpkgs.config.allowUnfree;
        };
      })
    ];

  };

}

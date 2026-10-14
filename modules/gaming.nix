{ ... }: {

  flake.nixosModules.gaming = { pkgs, ... }: {
    
    # Install steam
    programs.steam.enable = true;

  };

}

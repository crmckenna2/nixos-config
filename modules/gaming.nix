{ ... }: {

  flake.nixosModules.gaming = { pkgs, ... }: {
    
    # Install steam
    programs.steam.enable = true;

    # Set up homm3
    environment.systemPackages = with pkgs; [
      wineWow64Packages.full
      minigalaxy
    ];

  };

}

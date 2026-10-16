{ ... }: {

  flake.nixosModules.gaming = { pkgs, ... }: {
    
    # Install steam
    programs.steam.enable = true;

    environment.systemPackages = with pkgs; [
      minigalaxy
      wineWow64Packages.full
    ];

  };

}

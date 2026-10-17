{ ... }: {

  flake.nixosModules.gaming = { pkgs, ... }: {
    
    # Install steam
    programs.steam.enable = true;

    environment.systemPackages = with pkgs; [
      wineWow64Packages.full
      xvfb-run
    ];

  };

}

{ ... }: {

  flake.nixosModules.gaming = { pkgs, ... }: {
    
    # Install steam
    programs.steam.enable = true;

    environment.systemPackages = with pkgs; [

      # Set up homm3
      wineWow64Packages.full
      xvfb-run

      # Minecraft
      (prismlauncher.override {
        jdks = [ jdk25 ];
        additionalLibs = [ ocl-icd ];
      })

    ];

  };

}

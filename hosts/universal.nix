{ self, inputs, ... }: {

  flake.nixosModules.universal = { pkgs, ... }: {

    # Universal packages
    environment.systemPackages = with pkgs; [
      git
      btop
    ];

    # Network manager
    networking.networkmanager.enable = true;
    networking.nameservers = [ "9.9.9.9" "149.112.112.112" "193.138.219.74" "193.138.218.74" ];
    services.resolved.enable = true;

    # Language and time zone
    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "America/Chicago";

    # Keyboard layout
    services.xserver.xkb.layout = "us";
    services.xserver.xkb.variant = "querty";

    # Unfree software
    nixpkgs.config.allowUnfree = true;

    # Experimental nix features
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Security
    security.sudo.wheelNeedsPassword = false; 

  };

}

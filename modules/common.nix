{ ... }: {

  flake.nixosModules.common = { pkgs, ... }: {

    # Universal packages
    environment.systemPackages = with pkgs; [
      git
      btop
      nix-index
      comma
      nh
    ];

    # Network manager
    networking.networkmanager.enable = true;
    networking.nameservers = [ "9.9.9.9" "149.112.112.112" "193.138.219.74" "193.138.218.74" ];
    services.resolved.enable = true;

    # Personalized networking
    networking.hosts = {
      "0.0.0.0" = [
        #"www.youtube.com"
        "m.youtube.com"
        "youtube.com"
      ];
    };

    # Language and time zone
    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "America/Chicago";

    # Keyboard layout
    services.xserver.xkb.layout = "us";
    services.xserver.xkb.variant = "querty";

    # Unfree software
    nixpkgs.config.allowUnfree = true;

    # Nix configuration
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.settings.use-xdg-base-directories = true;
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Prevent home manager from double installing packages
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    # Security
    security.sudo.wheelNeedsPassword = false; 
    nix.settings.trusted-users = [ "root" "@wheel" ];

  };

}

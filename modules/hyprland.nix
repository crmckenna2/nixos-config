{ self, inputs, ... }: {

  flake.nixosModules.hyprland = { pkgs, ... }: {

    # Enable hyprland
    programs.hyprland.enable = true;
    programs.hyprland.withUWSM = true;

    # Launch hyprland at startup
    services.greetd = {
      enable = true;
      settings = rec {
        initial_session = {
	  command = "uwsm start hyprland.desktop";
	  user = "cody";
	};
        default_session = initial_session;
      };
    };

    # Enable hyprland portals
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };

    # Install the supporting packages
    environment.systemPackages = with pkgs; [
      qt6.qtwayland
      libsForQt5.qtwayland
      brightnessctl
      playerctl
      slurp
      grim
      foot
      fuzzel
      librewolf
      bluetui
      wev
      qutebrowser
    ];

    # Configure the system audio
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    # Bluetooth configuration
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        Policy = {
	  Experimental = true;
	};
      };
    };

    # Configure electron apps to use wayland natively
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

  };

  flake.homeModules.hyprland = { pkgs, config, ... }: {

    # Enable the notification daemon
    #services.mako.enable = true;

    # Enable the polkit agent
    services.hyprpolkitagent.enable = true;

  };

}

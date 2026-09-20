{ self, inputs, ... }: {

  flake.nixosModules.hyprland = { pkgs, ... }: {

    # Enable hyprland
    programs.hyprland.enable = true;

    # Install the supporting packages
    environment.systemPackages = with pkgs; [
      hyprpolkitagent
      brightnessctl
      qt6.qtwayland
      libsForQt5.qtwayland
      playerctl
      wev
      foot
      fuzzel
      bluetui
      librewolf
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

  flake.homeModules.hyprland = { pkgs, ... } : {

    # Enable support for user daemons
    wayland.windowManager.hyprland.systemd.enable = true;

  };

}

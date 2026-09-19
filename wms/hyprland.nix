{ self, inputs, ... }: {

  flake.nixosModules.hyprland = { pkgs, ... }: {

    # Enable hyprland
    programs.hyprland.enable = true;

    # Install the supporting packages
    environment.systemPackages = with pkgs; [
      xdg-desktop-portal-hyprland
      hyprpolkitagent
      brightnessctl
      qt6-wayland
      qt5-wayland
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

}

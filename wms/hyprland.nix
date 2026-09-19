{ self, inputs, ... }: {

  flake.nixosModules.hyprland = { pkgs, ... }: {

    # Enable hyprland
    programs.hyprland.enable = true;
    programs.hyprland.withUWSM = true;

    # Install the supporting packages
    environment.systemPackages = with pkgs; [
      hyprpolkitagent
      brightnessctl
      #qt6.qtwayland
      #libsForQt5.qtwayland
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

    # Configure session variables for Nvidia & wayland 
    environment.sessionVariables = {
      #__GLX_VENDOR_LIBRARY_NAME = "nvidia";
      #LIBVA_DRIVER_NAME = "nvidia";
      NIXOS_OZONE_WL = "1";
      #ELECTRON_OZONE_PLATFORM_HINT = "auto";
      #XDG_SESSION_TYPE = "wayland";
    };

  };

}

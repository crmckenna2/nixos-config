{ self, inputs, ... }: {

  flake.nixosModules.hyprland = { pkgs, ... }: {

    # Enable hyprland
    programs.hyprland.enable = true;

    # Install the supporting packages
    environment.systemPackages = with pkgs; [
      bluetui
      kitty
      fastfetch
      librewolf
    ];

    # Configure the system audio
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
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

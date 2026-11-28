{ self, inputs, ... }: {

  flake.nixosConfigurations.nixberry = inputs.nixos-raspberrypi.lib.nixosSystem {

    specialArgs = inputs;
    
    modules = with inputs.nixos-raspberrypi.nixosModules; [
      inputs.home-manager.nixosModules.home-manager

      raspberry-pi-5.base
      raspberry-pi-5.bluetooth

      self.nixosModules.nixberry
      self.nixosModules.common
      self.nixosModules.networking
      self.nixosModules.cody
    ];

  };
  
  flake.nixosModules.nixberry = { config, ... }: {

    # Set the hostname
    networking.hostName = "nixberry";

    # Declare the system state version
    system.stateVersion = "26.05";
    home-manager.users.cody.imports = [
      self.homeModules.nixberry
    ];

    # Run a LAN backup openssh server
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
    users.users.cody.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE09e8G+Ld280G5pzrxJbLXUR58VbZP+9v7h776MywXK crmckenna2@wisc.edu"
    ];

    # Publish the hostname for mDNS
    services.avahi.publish  = {
      enable = true;
      addresses = true;
    };


    # Use modern boot method
    boot.loader.raspberry-pi.bootloader = "kernel";

    # System tags for the nixos-raspberrypi system setup
    system.nixos.tags = [
      "raspberry-pi-${config.boot.loader.raspberry-pi.variant}"
      config.boot.loader.raspberry-pi.bootloader
      config.boot.kernelPackages.kernel.version
    ];

    # Use the nixos-raspberrypi cache instead of building pi kernel from source
    nix.settings = {
      substituters = [
        "https://nixos-raspberrypi.cachix.org"
      ];
      trusted-public-keys = [
        "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      ];
    };

    # Filesystem configuration
    fileSystems = {
      "/boot/firmware" = {
        device = "/dev/disk/by-label/FIRMWARE";
        fsType = "vfat";
        options = [
          "noatime"
          "noauto"
          "x-systemd.automount"
          "x-systemd.idle-timeout=1min"
        ];
      };
     "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
      };
    };

  };

  flake.homeModules.nixberry = { ... } : {
  
     # Declare initial install version of home manager
     home.stateVersion = "26.05";

  };

}

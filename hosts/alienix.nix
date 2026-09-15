{ self, inputs, ... }:

{

  flake.nixosConfigurations.alienix = inputs.nixpkgs.lib.nixosSystem {

    # Declare the nixos modules for the machine
    modules = [
      inputs.home-manager.nixosModules.home-manager
      self.nixosModules.alienix
      self.nixosModules.cody
      self.nixosModules.hyprland
    ];

  };

  flake.nixosModules.alienix = {config, lib, pkgs, modulesPath, ... }: {

    # Manage the hardware settings
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    # Kernel modules
    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    # Root and boot drives
    fileSystems."/" = { 
      device = "/dev/disk/by-uuid/4da8a858-38d8-4bd7-b982-ecad997c5588";
      fsType = "ext4";
    };
    fileSystems."/boot" = { 
      device = "/dev/disk/by-uuid/BA84-9990";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    # RAM swap
    swapDevices = [ ];

    # CPU architechture
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    # SETTINGS ABOVE THIS ARE SET BY THE OS 
    # DO NOT MODIFY SETTINGS ABOVE THIS MESSAGE
    # SETTINGS BELOW THIS MAY BE MODIFIED, WITH CAUTION

    # Set the hostname
    networking.hostName = "alienix";

    # Declare the system state version
    system.stateVersion = "26.05";

    # Nvidia and graphical settings
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.graphics.enable = true;
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };

    # Bootloader settings
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Kernel version
    boot.kernelPackages = pkgs.linuxPackages_latest;

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


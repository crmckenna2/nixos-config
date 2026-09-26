{ self, inputs, ... }:

{

  flake.nixosConfigurations.alienix = inputs.nixpkgs.lib.nixosSystem {

    # Declare the nixos modules for the machine
    modules = [
      inputs.home-manager.nixosModules.home-manager
      self.nixosModules.universal
      self.nixosModules.alienix
      self.nixosModules.cody
      self.nixosModules.hyprland
      self.nixosModules.development
    ];

  };

  flake.nixosModules.alienix = {config, lib, pkgs, modulesPath, ... }: {

    # Set the hostname
    networking.hostName = "alienix";

    # Declare the system state version
    system.stateVersion = "26.05";
    home-manager.users.cody.imports = [
     self.homeModules.alienix
    ];

    # Nvidia and graphical settings
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.graphics.enable = true;
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };

    # Set up communication utility for the monitor
    environment.systemPackages = with pkgs; [
      ddcutil
    ];
    hardware.i2c.enable = true;
    

    # IMPORTANT: The code below this line is mostly written by the OS
    # Be very deliberate when considering changes to the code below
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    # Kernel modules
    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ "nvidia" "nvidia-modeset" "nvidia-uvm" "nvidia-drm" ];
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

    # Bootloader settings
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Kernel version
    boot.kernelPackages = pkgs.linuxPackages_latest;

  };

  flake.homeModules.alienix = { ... } : {
  
     # Declare initial install version of home manager
     home.stateVersion = "26.05";

  };

}


{ self, inputs, ... }: {

  flake.nixosConfigurations.nixps = inputs.nixpkgs.lib.nixosSystem {

    # Declare the nixos modules for the machine
    modules = [
      inputs.home-manager.nixosModules.home-manager
      self.nixosModules.universal
      self.nixosModules.nixps
      self.nixosModules.cody
      self.nixosModules.hyprland
      self.nixosModules.development
    ];

  };

  flake.nixosModules.nixps = { config, pkgs, lib, modulesPath, ... }: {

    # Set the host name
    networking.hostName = "nixps";

    # Declare the nixos installation version
    system.stateVersion = "25.11";
    home-manager.users.cody.imports = [
      self.homeModules.nixps
    ];

    # Graphical settings
    hardware.graphics.enable = true;

    # IMPORTANT: The code below this line is written by the OS
    # Be very deliberate when considering changes to the code below
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    # Kernel modules
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "vmd"
      "nvme" "usb_storage" "sd_mod"
      "rtsx_pci_sdmmc"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    # Root and boot drives
    fileSystems."/" = {
      device = "/dev/disk/by-uuid/947ebe50-f54e-4d85-a2a6-b2fbfcfa228a";
      fsType = "ext4";
    };
    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/3767-AEEB";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

    # RAM swap
    swapDevices = [ ];

    # CPU architechture
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    # Bootloader
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Kernel version
    boot.kernelPackages = pkgs.linuxPackages_latest;

  };

  flake.homeModules.nixps = { ... } : {
  
     # Declare initial install version of home manager
     home.stateVersion = "25.11";

  };

}

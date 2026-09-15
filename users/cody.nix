{ self, inputs, ...}: {

  flake.nixosModules.cody = { pkgs, config, ...}: {

    users.users.cody = {
    
      isNormalUser = true;
      description = "cody";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
        git
        neovim
        fishMinimal
	direnv
        tree
	cascadia-code
	sl
      ];

      # Set the default shell
      shell = pkgs.fish;

    };

    # Enable the default shell
    programs.fish.enable = true;

    # Enable user fonts
    fonts.packages = with pkgs; [
      cascadia-code
    ];

    # Configure home manager modules
    home-manager.users.cody.imports = [
      self.homeModules.cody
    ];

    # Prevent home manager from double installing packages
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

  };

  flake.homeModules.cody = { pkgs, ... } : {

    # Provide basic system info
    home.username = "cody";
    home.homeDirectory = "/home/cody";
    home.stateVersion = "26.05";

    # Enable home manager
    programs.home-manager.enable = true;

    # Clean up the home directory
    xdg.enable = true;

    # Symlink the dotfiles
    home.file.".config" = {
      source = ../dotfiles/config;
      recursive = true;
    };

  };

}

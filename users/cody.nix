{ self, inputs, ...}: {

  flake.nixosModules.cody = { pkgs, ...}: {

    users.users.cody = {
    
      isNormalUser = true;
      description = "cody";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
        neovim
        fishMinimal
	direnv
        tree
	cascadia-code
	fzf
      ];

      # Set the default shell
      shell = pkgs.fish;

    };

    # Set the default shell to fish
    programs.fish.enable = true;

    # Enable user fonts
    fonts.packages = with pkgs; [
      cascadia-code
    ];

    # Configure home manager modules
    home-manager.users.cody.imports = [
      self.homeModules.cody
      self.homeModules.hyprland
    ];

  };

  flake.homeModules.cody = { pkgs, config, ... } : {

    # Provide basic user info
    home.username = "cody";
    home.homeDirectory = "/home/cody";

    # Enable home manager
    programs.home-manager.enable = true;

    # Clean up the home directory
    xdg.enable = true;

    # Symlink the dotfiles
    home.file.".config" = {
      source = ../dotfiles/.config;
      recursive = true;
      force = true;
    };

    # Move default directories out of the home directory
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
      desktop = "${config.home.homeDirectory}/files/desktop";
      documents = "${config.home.homeDirectory}/files/documents";
      download = "${config.home.homeDirectory}/files/downloads";
      music = "${config.home.homeDirectory}/files/music";
      pictures = "${config.home.homeDirectory}/files/pictures";
      projects = "${config.home.homeDirectory}/files/projects";
      publicShare = "${config.home.homeDirectory}/files/public-share";
      templates = "${config.home.homeDirectory}/files/templates";
      videos = "${config.home.homeDirectory}/files/videos";
    };

    # Communication layer for bluetooth headphone buttons
    services.mpris-proxy.enable = true;

  };

}

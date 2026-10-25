{ ... }: {

  flake.nixosModules.development = { pkgs, ... }: {

    # Packages
    environment.systemPackages = with pkgs; [

      # Compilers
      gcc

      # General utilities
      git
      tree
      ripgrep
      fzf
      fd

      # Nix development
      nix-index
      nix-direnv
      direnv
      comma
      nixd
      nh

      # Lua development
      lua-language-server

    ];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

  };

}

{ self, inputs, ... }: {

  flake.nixosModules.development = { pkgs, ... }: {

    # Packages
    environment.systemPackages = with pkgs; [

      # General utilities
      git
      neovim
      tree
      fzf

      # Nix development
      direnv
      nixd
      nh

      # Lua development
      lua-language-server

    ];

  };

}

{ ... }: {

  flake.nixosModules.development = { pkgs, ... }: {

    # Packages
    environment.systemPackages = with pkgs; [

      # General utilities
      git
      tree
      ripgrep
      fzf

      # Nix development
      nix-index
      direnv
      comma
      nixd
      nh

      # Lua development
      lua-language-server

    ];

  };

}

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
      fd

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

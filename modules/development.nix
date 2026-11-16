{ ... }: {

  flake.nixosModules.development = { pkgs, ... }: {

    # Packages
    environment.systemPackages = with pkgs; [

      # Compilers
      gcc

      # General utilities
      git
      tmux
      tree
      ripgrep
      fzf
      fd

      # Nix development
      nix-index
      comma
      nh

      # Agentic development
      pi-coding-agent
      mcp-nixos
      graphify
      wl-clipboard

    ];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

  };

}

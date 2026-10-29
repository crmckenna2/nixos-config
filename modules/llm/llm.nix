{ self, ... }: {

  flake.nixosModules.llm = { pkgs, ... }: {

    # Create a user for llms to operate under
    users.users.llm = {

      isNormalUser = true;
      name = "llm";
      home = "/home/llm";

      packages = with pkgs; [

        # Agentic coding
        opencode

        # Nix support for the agents
        direnv
        nix-direnv
        nix-index

        # Other utilites
        git
        ripgrep
        fd

      ];

    };

    # Enable direnv
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Ollama settings
    services.ollama = {

      enable = true;

      # Use nvidia gpu for llm inference
      package = pkgs.ollama-cuda;

      # Declaratively manage model installation
      syncModels = true;
      loadModels = [
        "deepseek-r1:8b"
        "llama3.1"
        "hf.co/DavidAU/Qwen3.5-9B-The-Defiant-Fable-Uncensored-Heretic-NEO-IMATRIX-MAX-MTP-GGUF:Q4_K_M"
        "huihui_ai/qwen3-vl-abliterated:8b-instruct"
      ];

    };

    home-manager.users.llm.imports = [
      self.homeModules.llm
    ];

  };

  flake.homeModules.llm = { ... }: {
    
    # Provide basic user info
    home.username = "llm";
    home.homeDirectory = "/home/llm";
    home.stateVersion = "26.05";

    # Enable home manager
    programs.home-manager.enable = true;

    # Clean up the home directory
    xdg.enable = true;

    # Symlink the opencode config
    home.file.".config/opencode" = {
      source = ./opencode-config;
      recursive = true;
      force = true;
    };

  };

}

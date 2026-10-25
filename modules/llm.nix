{ ... }: {

  flake.nixosModules.llm = { pkgs, ... }: {

    # Create a user for llms to operate under
    users.users.llm = {

      isNormalUser = true;
      name = "llm";
      home = "/home/llm";

      packages = with pkgs; [

        # Agentic coding
        opencode

        # Nix support the agents
        direnv

      ];

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

  };

}

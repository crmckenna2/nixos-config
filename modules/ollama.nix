{ ... }: {

  flake.nixosModules.ollama = { pkgs, config, ... }: {

    # Create a user for ollama to operate under
    users.users.ollama = {

      name = "ollama";
      home = "/home/ollama";

    };

    # Ollama settings
    services.ollama = {

      enable = true;

      # Use nvidia gpu for llm inference
      package = pkgs.ollama-cuda;

      # Declaratively manage model installation syncModels = true;
      loadModels = [
        #"hf.co/DavidAU/Qwen3.5-9B-The-Defiant-Fable-Uncensored-Heretic-NEO-IMATRIX-MAX-MTP-GGUF:Q4_K_M"
      ];

      # Direct ollama to the above user
      user = "ollama";
      home = "/home/ollama";
      models = "/home/ollama/models";

    };

  };

}

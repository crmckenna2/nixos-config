{ ... }: {

  flake.nixosModules.llm = { pkgs, ... }: {

    # Use the nixos cuda cache instead of compiling from source
    nix.settings = {
      substituters = [
        "https://cache.nixos-cuda.org"
      ];
      trusted-public-keys = [
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
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

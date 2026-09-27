{ ... } : {

  flake.homeModules.neovim = { pkgs, ... } : {

    # Configure neovim
    programs.neovim = {

      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      extraPackages = with pkgs; [

        # Nix LSP
        nixd

        # Lua LSP
        lua-language-server

        # QML LSP, yes that is the package name
        kdePackages.qtdeclarative

      ];

      plugins = with pkgs.vimPlugins; [

        # Treesitter and its parsers
        (nvim-treesitter.withPlugins ( plugins : with plugins; [
          
          # Programming languages
          nix
          lua
          qmljs

          # Other utilities
          markdown
          json
          csv

        ]))

        # LSP config
        nvim-lspconfig

      ];

      initLua = ''require("main")'';

    };

  };

}

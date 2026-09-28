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

        # Telescope.nvim and its dependencies
        telescope-nvim

      ];

      # Include my non-nix managed neovim config
      initLua = ''require("init")'';

      # Prevent nixps from yelling at me
      withPython3 = false;
      withRuby = false;

    };

  };

}

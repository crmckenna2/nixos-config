{ ... }: {

  flake.homeModules.zed = { ... }: {

    programs.zed-editor = {
      enable = true;
      extensions = [ "nix" "lua" "c#" ];
      userSettings = {
        hour_format = "hour24";
        vim_mode = true;
      };
    };

  };

}

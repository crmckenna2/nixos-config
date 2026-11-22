{ ... }: {

flake.homeModules.zed = { pkgs, lib, ... }: {

  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" "lua" "c#" ];

    extraPackages = with pkgs; [
      nixd
      lua-language-server
      omnisharp-roslyn
      dotnet-sdk
    ];

    userSettings = {
      hour_format = "hour24";
      vim_mode = true;

      lsp = {
        nixd = {
          binary = {
            path = lib.getExe pkgs.nixd;
          };
        };
        lua-language-server = {
          binary = {
            path = lib.getExe pkgs.lua-language-server;
          };
        };
        omnisharp = {
          binary = {
            path = lib.getExe pkgs.omnisharp-roslyn;
          };
        };
      };
    };
  };

};

}

{ ... } : {

  flake.nixosModules.browsers = { pkgs, ... } : {

    environment.systemPackages = with pkgs; [

      # Daily-driver browser with spotify support
      (qutebrowser.override { enableWideVine = true; })
    
      # Security oriented browser
      librewolf

      # TOR browser
      tor-browser
      
    ];

  };

}

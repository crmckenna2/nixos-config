{ ... }: {

  flake.nixosModules.networking = { ... }: {

    # General networking and wifi management
    networking.networkmanager.enable = true;

    # Mesh VPN
    services.tailscale = {
      enable = true;
      openFirewall = true;
      extraSetFlags = [
        "--ssh"
      ];
    };

    # DNS servers Quad9 then Mullvad
    networking.nameservers = [ "9.9.9.9" "149.112.112.112" "193.138.219.74" "193.138.218.74" ];
    services.resolved.enable = true;

    # Domain blacklist 
    networking.hosts = {
      "0.0.0.0" = [
        "www.youtube.com"
      ];
    };

    # MulticastDNS resolver
    services.avahi = {
      enable = true;
      nssmdns4= true;
    };

  };

}

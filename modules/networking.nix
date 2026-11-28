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

    # Avahi local network device discovery
    services.avahi = {
      enable = true;
      nssmdns4= true;
      publish = {
        enable = true;
        addresses = true;
      };
    };

    # Run an openssh server
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };

    users.users.cody.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE09e8G+Ld280G5pzrxJbLXUR58VbZP+9v7h776MywXK crmckenna2@wisc.edu"
    ];

  };

}

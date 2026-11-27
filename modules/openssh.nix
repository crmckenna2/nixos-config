{ ... }: {

  flake.nixosModules.openssh = { ... }: {

    services.avahi = {
      enable = true;
      nssmdns4= true;
      publish = {
        enable = true;
        addresses = true;
      };
    };

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };

    users.users.cody.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE09e8G+Ld280G5pzrxJbLXUR58VbZP+9v7h776MywXK crmckenna2@wisc.edu"
    ];

  };

}

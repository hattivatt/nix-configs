{
  flake.modules.nixos.networkmanager = {
    my.persist.directories = [
      "/var/lib/NetworkManager"
      "/etc/NetworkManager/system-connections"
    ];
  };
}


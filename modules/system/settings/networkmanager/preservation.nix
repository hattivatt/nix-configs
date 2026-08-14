{
  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist".directories = [
      "/var/lib/NetworkManager"
      "/etc/NetworkManager/system-connections"
    ];
  };
}


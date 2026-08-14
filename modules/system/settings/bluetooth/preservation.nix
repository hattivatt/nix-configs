{
  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist".directories = [
      "/var/lib/bluetooth"
    ];
  };
}


{
  flake.modules.nixos.bluetooth = {
    my.persist.directories = [
      "/var/lib/bluetooth"
    ];
  };
}


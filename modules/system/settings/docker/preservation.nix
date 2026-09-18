{
  flake.modules.nixos.docker = {
    my.persist.directories = [
      "/var/lib/docker"
    ];
  };
}


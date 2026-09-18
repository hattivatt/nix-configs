{
  flake.modules.nixos.caddy =
  {
    my.persist.directories = [
      "/var/lib/caddy"
    ];
  };
}

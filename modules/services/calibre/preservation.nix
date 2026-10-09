{
  flake.modules.nixos.calibre =
  {
    my.persist.directories = [
      "/var/lib/calibre-web"
      "/var/lib/calibre-library"
    ];
  };
}

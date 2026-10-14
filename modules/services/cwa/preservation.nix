{
  flake.modules.nixos.cwa =
  {
    my.persist.directories = [
      {
        directory = "/var/lib/calibre-web";
        group = "calibre-web-automated";
        user = "calibre-web-automated";
      }
      {
        directory = "/var/lib/calibre-library";
        group = "calibre-web-automated";
        user = "calibre-web-automated";
      }
    ];
  };
}

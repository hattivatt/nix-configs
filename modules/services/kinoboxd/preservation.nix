{
  flake.modules.nixos.kinoboxd = {
    my.persist.directories = [
      {
        directory = "/var/lib/kinoboxd";
        group = "kinoboxd";
        user = "kinoboxd";
      }
    ];
  };
}

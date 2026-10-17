{
  flake.modules.nixos.koinsight = {
    my.persist.directories = [
      {
        directory = "/var/lib/koinsight";
        group = "koinsight";
        user = "koinsight";
      }
    ];
  };
}

{
  flake.modules.nixos.koinsight = {
    my.persist.directories = [
      "/var/lib/koinsight"
    ];
  };
}

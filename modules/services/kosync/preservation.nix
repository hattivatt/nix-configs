{
  flake.modules.nixos.kosync = {
    my.persist.directories = [
      {
        directory = "/var/lib/kosync";
        group = "kosync";
        user = "kosync";
      }
    ];
  };
}

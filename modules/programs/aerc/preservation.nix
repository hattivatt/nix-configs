{
  flake.modules.homeManager.aerc = {
    my.persist.directories = [
      {
        directory = ".local/state/aerc";
        mode = "0700";
      }
    ];
  };
}

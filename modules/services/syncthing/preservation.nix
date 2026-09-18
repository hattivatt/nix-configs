{
  flake.modules.homeManager.syncthing = {
    my.persist.directories = [
      {
        directory = ".local/state/syncthing";
        mode = "0700";
      }
    ];
  };
}

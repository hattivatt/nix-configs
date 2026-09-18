{
  flake.modules.homeManager.zathura = {
    my.persist.directories = [
      {
        directory = ".local/share/zathura";
        mode = "0700";
      }
    ];
  };
}

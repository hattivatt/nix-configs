{
  flake.modules.homeManager.nixvim = {
    my.persist.directories = [
      {
        directory = ".local/state/nvim";
        mode = "0700";
      }
    ];
  };
}

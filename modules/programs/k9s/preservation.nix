{
  flake.modules.homeManager.k9s = {
    my.persist.directories = [
      ".local/share/k9s"
    ];
  };
}

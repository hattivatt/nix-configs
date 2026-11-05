{
  flake.modules.homeManager.gopass = {
    my.persist.directories = [
      ".local/share/pass"
      ".local/share/passage"
    ];
  };
}

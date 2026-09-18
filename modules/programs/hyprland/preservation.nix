{
  flake.modules.homeManager.hyprland = {
    my.persist.directories = [
      {
        directory = ".local/share/hyprland";
        mode = "0700";
      }
    ];
  };
}

{
  flake.modules.homeManager.desktop-apps = {
    my.persist.directories = [
      "Downloads"
      "Documents"
      "Pictures"
      "Projects"
      ".config/Exodus"
      ".config/kdeconnect"
      ".config/spotify"
      ".steam"
      {
        directory = ".local/state/wireplumber";
        mode = "0700";
      }
    ];
  };
}

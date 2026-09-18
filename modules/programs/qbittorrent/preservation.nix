{
  flake.modules.homeManager.qbittorrent = {
    my.persist.directories = [
      ".local/share/qBittorrent"
    ];
  };
}

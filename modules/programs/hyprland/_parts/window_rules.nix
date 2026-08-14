{
  wayland.windowManager.hyprland.settings = {
      workspace_rule = {workspace = "w[tv1]"; gaps_in = 0; gaps_out = 0; border_size = 0;};
      window_rule = [
        {match = {class = "obsidian";}; workspace = "10 silent";}
        {match = {class = "md.Obsidian";}; workspace = "10 silent";}
        {match = {class = "zen";}; workspace = "1 silent";}
        {match = {class = "zen-beta";}; workspace = "1 silent";}
        {match = {class = "org.telegram.desktop";}; workspace = "2 silent";}
        {match = {class = "mattermost-desktop";}; workspace = "2 silent";}
        {match = {class = "Mattermost";}; workspace = "2 silent";}
        {match = {class = "Mattermost.Desktop";}; workspace = "2 silent";}
        {match = {class = "vesktop";}; workspace = "2 silent";}
        {match = {class = "slack";}; workspace = "2 silent";}
        {match = {class = "steam";}; workspace = "4 silent";}
        {match = {class = "lutris";}; workspace = "4 silent";}
        {match = {class = "pcmanfm-qt";}; workspace = "5 silent";}
        {match = {class = "mpv";}; workspace = "6";}
        {match = {title = "^(Steam - News.*)$";}; float = true;}
        {match = {title = "^(Copy Files.*)$";}; float = true;}
        {match = {title = "^(Media viewer)$";}; float = true; fullscreen = true;}
        {match = {class = "org.gnupg.pinentry-qt";}; float = true; stay_focused = true;}
        {match = {class = "imv ";};float = true;}
        {match = {class = "org.kde.polkit-kde-authentication-agent-1";}; float = true;}
        {match = {class = "com.gabm.satty ";}; float = true;}
        {match = {class = "xdg-desktop-portal-gtk ";};float = true;}
        {match = {class = "Windscribe ";};float = true;}
        {match = {class = "Spotify";}; workspace = "special:sp silent";}
        {match = {class = "spotify";}; workspace = "special:sp silent";}
        {match = {class = "org.qbittorrent.qBittorrent";}; workspace = "special:qb silent";}
        {match = {class = "org.mozilla.Thunderbird";}; workspace = "special:th silent";}
        {match = {class = "aerc";}; workspace = "special:th silent";}
        {match = {class = "khal";}; workspace = "special:th silent";}
        {match = {class = "txtbuff";}; workspace = "special:txtbuff silent";}
        {match = {class = "org.telegram.desktop";}; scrolling_width = 0.98;}
        {match = {class = "mattermost-desktop";}; scrolling_width = 0.98;}
        {match = {class = "Mattermost";}; scrolling_width = 0.98;}
        {match = {class = "Mattermost.Desktop";}; scrolling_width = 0.98;}
        {match = {class = "vesktop";}; scrolling_width = 0.98;}
        {match = {class = "slack";}; scrolling_width = 0.98;}
      ];
      monitor = {output = ""; mode = "preferred"; position = "auto"; scale = 1;};
  };
}

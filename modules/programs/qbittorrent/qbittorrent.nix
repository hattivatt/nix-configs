{
  flake.modules.homeManager.qbittorrent =
  { pkgs, ... }:
  {
    home.packages = with pkgs; [
      qbittorrent
    ];
    xdg.configFile."qBittorrent/qBittorrent.conf".text = ''
      [AddNewTorrentDialog]
      DialogSize=@Size(951 1038)
      DownloadPathHistory=
      Enabled=false
      RememberLastSavePath=false
      SavePathHistory=/home/hattivatt/Downloads/MoviesAndShows

      [Appearance]
      ColorScheme=Dark
      Style=kvantum

      [Application]
      FileLogger\Age=1
      FileLogger\AgeType=1
      FileLogger\Backup=true
      FileLogger\DeleteOld=true
      FileLogger\Enabled=true
      FileLogger\MaxSizeBytes=66560
      FileLogger\Path=/home/hattivatt/.local/share/qBittorrent/logs
      GUI\Notifications\TorrentAdded=false

      [BitTorrent]
      Session\DisableAutoTMMByDefault=false
      Session\Port=36417
      Session\QueueingSystemEnabled=false
      Session\SSL\Port=51386
      Session\StartPaused=false

      [Core]
      AutoDeleteAddedTorrentFile=Never

      [GUI]
      DownloadTrackerFavicon=false
      Log\Enabled=false
      MainWindow\FiltersSidebarWidth=229
      Qt6\AddNewTorrentDialog\SplitterState=@ByteArray(\0\0\0\xff\0\0\0\x1\0\0\0\x2\0\0\x1\xf9\0\0\x1\xd0\0\xff\xff\xff\xff\x1\0\0\0\x1\0)
      Qt6\TransferList\HeaderState=@ByteArray(\0\0\0\xff\0\0\0\0\0\0\0\x1\0\0\0\x1\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0&\t\x90\xff\x7f?\0\0\0\x19\0\0\0\x1c\0\0\0\x64\0\0\0\xf\0\0\0\x64\0\0\0\x19\0\0\0\x64\0\0\0\x1a\0\0\0\x64\0\0\0%\0\0\0\x64\0\0\0\x1b\0\0\0\x64\0\0\0\x18\0\0\0\x64\0\0\0\x11\0\0\0\x64\0\0\0\x17\0\0\0\x64\0\0\0\x12\0\0\0\x64\0\0\0\x16\0\0\0\x64\0\0\0\0\0\0\0+\0\0\0\x13\0\0\0\x64\0\0\0\x10\0\0\0\x64\0\0\0!\0\0\0\x64\0\0\0$\0\0\0\x64\0\0\0 \0\0\0\x64\0\0\0#\0\0\0\x64\0\0\0\f\0\0\0\x64\0\0\0\x15\0\0\0\x64\0\0\0\x3\0\0\0\x64\0\0\0\x1e\0\0\0\x64\0\0\0\"\0\0\0\x64\0\0\0\x14\0\0\0\x64\0\0\0\x1d\0\0\0\x64\0\0\x6\xad\0\0\0&\x1\x1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x64\xff\xff\xff\xff\0\0\0\x81\0\0\0\0\0\0\0&\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\x1\xfd\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\x64\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\x1\0\0\0\0\0\0\x3\xe8\0\0\0\0\x64\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\x1)
      StartUpWindowState=Normal

      [LegalNotice]
      Accepted=true

      [Meta]
      MigrationVersion=8

      [OptionsDialog]
      HorizontalSplitterSizes=145, 619
      LastViewedPage=0
      Size=@Size(779 591)

      [Preferences]
      Advanced\confirmTorrentDeletion=false
      General\Locale=en
      Advanced\useSystemIconTheme=true
      General\ExitConfirm=false
      General\CloseToTray=false

      [RSS]
      AutoDownloader\DownloadRepacks=true
      AutoDownloader\SmartEpisodeFilter=s(\\d+)e(\\d+), (\\d+)x(\\d+), "(\\d{4}[.\\-]\\d{1,2}[.\\-]\\d{1,2})", "(\\d{1,2}[.\\-]\\d{1,2}[.\\-]\\d{4})"
    '';
    xdg.configFile."qBittorrent/categories.json".text = ''
      {
          "MoviesAndShows": {
              "download_path": null,
              "inactive_seeding_time_limit": -2,
              "ratio_limit": -2,
              "save_path": "/home/hattivatt/Downloads/MoviesAndShows",
              "seeding_time_limit": -2,
              "share_limit_action": "Default"
          },
          "OnePiece": {
              "download_path": null,
              "inactive_seeding_time_limit": -2,
              "ratio_limit": -2,
              "save_path": "/home/hattivatt/Downloads/MoviesAndShows/OnePiece",
              "seeding_time_limit": -2,
              "share_limit_action": "Default"
          }
      }
    '';
  };
}

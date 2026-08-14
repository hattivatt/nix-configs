{
  flake.modules.homeManager.flameshot =
  { config, ... }:
  {
    services.flameshot = {
      enable = true;
      settings = {
        General = {
          contrastOpacity = 188;
          disabledTrayIcon = true;
          showAbortNotification = false;
          showDesktopNotification = false;
          showHelp = true;
          showStartupLaunchMessage = false;
          savePath = "${config.home.homeDirectory}/Pictures/screenshots";
        };
      };
    };
  };
}

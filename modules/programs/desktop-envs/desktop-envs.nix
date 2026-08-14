{
  flake.modules.nixos.desktop-envs =
  {
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "ru_RU.UTF-8";
      LC_IDENTIFICATION = "ru_RU.UTF-8";
      LC_MEASUREMENT = "ru_RU.UTF-8";
      LC_MONETARY = "ru_RU.UTF-8";
      LC_NAME = "ru_RU.UTF-8";
      LC_NUMERIC = "ru_RU.UTF-8";
      LC_PAPER = "ru_RU.UTF-8";
      LC_TELEPHONE = "ru_RU.UTF-8";
      LC_TIME = "ru_RU.UTF-8";
    };
  };
  flake.modules.homeManager.desktop-envs =
  {
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      GDK_BACKEND = "wayland,x11";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      QT_QPA_PLATFORM = "wayland";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      DIFFPROG = "nvim -d";
      TERMINAL = "foot";
      BROWSER = "zen-browser";
      VIDEO = "mpv";
      IMAGE = "imv";
      COLORTERM = "truecolor";
      OPENER = "xdg-open";
      PAGER = "less";
      WM = "Hyprland";
      MOZ_ENABLE_WAYLAND = "1";
    };
  };
}

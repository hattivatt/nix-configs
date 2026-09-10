{
  flake.modules.nixos.desktop-apps =
  { pkgs, ... }:
  {
    environment.systemPackages = with pkgs; [
      git
      nfs-utils
      acpid
      acpilight
      gvfs
      lshw
      upower
      exfat
      btrfs-progs
    ];
    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.noto
      baekmuk-ttf
      open-sans
      weather-icons
    ];
    services = {
      libinput.enable = true;
    };
    networking.firewall = rec {
      allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
      allowedUDPPortRanges = allowedTCPPortRanges;
    };
  };
  flake.modules.homeManager.desktop-apps =
  { pkgs, ... }:
  {
    home.packages = with pkgs; [
      krita
      lxqt.lxqt-sudo
      lxqt.pcmanfm-qt
      miller
      mkvtoolnix
      spotify
      steam
      proton-vpn-cli
      playerctl
      wev
      wlr-which-key
      hyprland-autoname-workspaces
      tessen
      archivemount
      brightnessctl
      dragon-drop
      engrampa
      # exodus
      kubectl
      tenv
      zoxide
      kitty
      hyprsysteminfo
      p7zip
      chafa
      ffmpegthumbnailer
      gdu
      gtk-layer-shell
      ouch
      lxqt.pavucontrol-qt
      rsync
      slurp
      grim
      tldr
      trash-cli
      tumbler
      ueberzugpp
      unar
      unrar
      upscayl
      vault-bin
      webp-pixbuf-loader
      wget
      wl-clipboard
      xdg-ninja
      yamlfmt
      yamllint
      networkmanagerapplet
      udiskie
      browserpass
      cliphist
      lsof
      fzf
      dig
      libnotify
      devenv
      bubblewrap
      glow
      imagemagick
      libsixel
      local.autoskip
      local.calnotif
      local.mailnotif
      local.change_wp
      local.check_subs
      local.device-manager
      local.downloads_clear
      local.hide_all
      local.medialist
      local.mergesubs
      local.phone_battery
      local.rpr
      local.tmt
      local.vaultsearch
      local.workbackup
      local.zkn
    ];
    home.file.".gtk-bookmarks".text = ''
      file:///home/hattivatt/Downloads/Temporary Temporary
      file:///home/hattivatt/Downloads Downloads
      file:///home/hattivatt/Documents Documents
      file:///home/hattivatt/Projects Projects
      file:///home/hattivatt/Yandex.Disk Yandex.Disk
    '';
    services.kdeconnect.enable = true;
    xdg.portal = {
      extraPortals = with pkgs; [ lxqt.xdg-desktop-portal-lxqt ];
      config.hyprland = {
        default = [ "lxqt" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
      };
    };
    xdg.configFile."lxqt/filedialog.conf".text = ''
      [Sizes]
      SplitterPos=200
      WindowSize=@Size(1193 759)

      [View]
      BigIconSize=48
      Mode=Detailed
      ScrollPerPixel=true
      ShowThumbnails=true
      SmallIconSize=24
      SortColumn=name
      SortFolderFirst=true
      SortOrder=ascending
      ThumbnailIconSize=128
    '';
    xdg.configFile."autoskip/config.toml".text = ''
      title_words = ["remix", "cover", "dj", "mix"]
    '';
    programs.obs-studio = {
      enable = true;
      plugins = [ pkgs.obs-studio-plugins.obs-pipewire-audio-capture ];
    };
  };
}

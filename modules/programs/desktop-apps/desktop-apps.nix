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
      qbittorrent
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
      kdePackages.kdeconnect-kde
      browserpass
      cliphist
      lsof
      local.autoskip
      local.calnotif
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
  };
}

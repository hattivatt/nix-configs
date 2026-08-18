{ inputs, ... }:
{
  flake.modules.nixos.system-desktop = {
    imports = with inputs.self.modules.nixos; [
      system-cli
      hyprland
      desktop-envs
      desktop-apps
      flatpak
      obsidian-plugins
      greetd
      rebuild
    ];
  };
  flake.modules.homeManager.system-desktop = {
    imports = with inputs.self.modules.homeManager; [
      system-cli
      agents
      chats
      desktop-apps
      desktop-envs
      fbreader
      flatpak
      flyctl
      foot
      fuzzel
      hyprland
      imv
      k9s
      mpv
      obsidian
      pass
      quickshell
      theme
      tundra
      wl-kbptr
      yadisk
      zathura
      zen-browser
      helium
      xkb
      flameshot
      swaync
      syncthing
    ];
  };
}


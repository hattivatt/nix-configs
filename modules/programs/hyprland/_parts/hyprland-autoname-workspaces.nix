{ pkgs, ... }:
let
  toml = pkgs.formats.toml {};
in
{
  home.packages = with pkgs; [
    hyprland-autoname-workspaces
  ];
  xdg.configFile."hyprland-autoname-workspaces/config.toml".force = true;
  xdg.configFile."hyprland-autoname-workspaces/config.toml".source = toml.generate "config.toml" {
    version = "1.1.16";
    format = {
      dedup = true;
      dedup_inactive_fullscreen = false;
      delim = " ";
      client = "{icon}{delim}";
      client_active = "{icon}";
      workspace = "{clients}{delim}";
      workspace_empty = "{id}{delim}{clients}";
      client_dup = "{icon}{counter_sup}{delim}";
      client_dup_fullscreen = "[{icon}]{delim}{icon}{counter_unfocused_sup}";
      client_fullscreen = "[{icon}]{delim}";
    };
    class_active.DEFAULT = "{icon}";
    title_in_class = {
      "(firefox|chrom.*|zen)" = {
        "(?i)youtube" = "";
        ".*GitLab.*" = "";
      };
      "(foot)" = {
        "Yazi.*" = "";
        ".*Nvim.*" = "";
        ".*vpn.*" = "󰖂";
        "k9s" = "󱃾";
      };
    };
    workspaces_names = {
      "0" = "zero";
      "1" = "one";
      "2" = "two";
      "3" = "three";
      "4" = "four";
      "5" = "five";
      "6" = "six";
      "7" = "seven";
      "8" = "eight";
      "9" = "nine";
      "10" = "ten";
    };
    class = {
      DEFAULT = "󰫍";
      chromium = "󰢛";
      helium = "󰢛";
      "Gimp-2.10" = "";
      discord = "󰙯 ";
      vesktop = "󰙯 ";
      obsidian = "󱞂";
      krita = "";
      mpv = "";
      pavucontrol = "󰋋";
      slack = "󰒱 ";
      steam = "";
      "org.telegram.desktop" = "";
      udiskie = "";
      zen = "";
      foot = "";
      "pcmanfm-qt" = "";
      OpenLens = "󱃾";
      Freelens = "󱃾";
      mattermost-desktop = "";
      Mattermost = "";
      Exodus = "󰠓";
      "blueberry.py" = "󰂯";
      "Foundry Virtual Tabletop" = "󰢛";
      FBReader = "";
    };
    exclude = {
      "" = "^$";
    };
  };
}

{ lib, ... }:
let
  lua = lib.generators.mkLuaInline;
  on = event: body: {
    _args = [
      event
      (lua ''function() ${body} end'')
    ];
  };
  exec = cmd: ''hl.exec_cmd("${cmd}")'';
in
{
  wayland.windowManager.hyprland.settings.on = [
    (
      on "hyprland.start" ''
        ${exec "uwsm app -- dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"}
        ${exec "uwsm app -- quickshell --config /home/hattivatt/.config/quickshell/main"}
        ${exec "uwsm app -- hyprland-autoname-workspaces"}
        ${exec "uwsm app -- hyprpaper"}
        ${exec "sleep 2 && uwsm app -- change_wp"}
        ${exec "uwsm app -- nm-applet --indicator"}
        ${exec "uwsm app -- Telegram"}
        ${exec "uwsm app -- mattermost-desktop"}
        ${exec "uwsm app -- slack --use-angle=opengl"}
        ${exec "uwsm app -- vesktop"}
        ${exec "uwsm app -- zen-beta"}
        ${exec "uwsm app -- obsidian"}
        ${exec "uwsm app -- foot -a aerc -e aerc"}
        ${exec "sleep 3 && uwsm app -- foot -a khal  -e khal interactive"}
        ${exec "uwsm app -- pimsync daemon"}
        ${exec "uwsm app -- udiskie -s"}
        ${exec "uwsm app -- kdeconnect-indicator"}
        ${exec "uwsm app -- wl-paste --type text --watch cliphist store"}
        ${exec "uwsm app -- wl-paste --type image --watch cliphist store"}
        ${exec "uwsm app -- downloads_clear > /tmp/downloads_clear.log"}
        ${exec "uwsm app -- trash-empty > /tmp/trash_empty.log"}
        ${exec "uwsm app -- foot -a txtbuff -e nvim -n /tmp/txtbuff"}
        ${exec "uwsm app -- hyprland-per-window-layout"}
      ''
    )
  ];
}

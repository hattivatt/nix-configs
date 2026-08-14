{ pkgs, lib, ... }:
let
  mkMenu = menu: let
    configFile = pkgs.writeText "config.yaml"
      (lib.generators.toYAML {} {
        font = "JetBrainsMono Nerd Font 28";
        anchor = "center";
        background = "#1E1E2D";
        color = "#CDD6F4";
        border = "#F38BA8";
        separator = " ➜ ";
        border_width = 2;
        corner_r = 1;
        padding = 15;
        rows_per_column = 15;
        column_padding = 25;

        inherit menu;
      });
  in
    pkgs.writeShellScriptBin "my-menu" ''
      exec ${lib.getExe pkgs.wlr-which-key} ${configFile}
    '';
  lua = lib.generators.mkLuaInline;
  bind = key: action: {
    _args = [
      key
      (lua action)
    ];
  };
  exec = cmd: ''hl.dsp.exec_cmd("${cmd}")'';
  mvws = ws: ''hl.dsp.focus({ workspace = "${ws}"})'';
  mvwd = ws: ''hl.dsp.window.move({ workspace = "${ws}", follow = true})'';
  mvwddr = dr: ''hl.dsp.window.move({ direction = "${dr}"})'';
  mvwfs = dr: ''hl.dsp.focus({direction = "${dr}"})'';
  fs = mode: ''hl.dsp.window.fullscreen({ mode = "${mode}"})'';
  focusdr = dr: ''hl.dsp.focus({ direction = "${dr}"})'';
  submap = sm: ''hl.dsp.submap("${sm}")'';
in
{
  wayland.windowManager.hyprland = {
    settings.bind = [
      (bind "SUPER" (submap "main"))
      (bind "SUPER_L" (submap "main"))
      (bind "XF86AudioNext" (exec "uwsm app -- playerctl -p spotify next"))
      (bind "XF86AudioPrev" (exec "uwsm app -- playerctl -p spotify previous"))
      (bind "mouse:275" (exec ''uwsm app -- bash -c \"playerctl -p spotify loop $(case $(playerctl -p spotify loop) in Track) echo Playlist;; Playlist) echo None;; None) echo Track;; esac)\"''))
      (bind "mouse:276" (exec "uwsm app -- playerctl -p spotify shuffle toggle"))
      (bind "XF86MonBrightnessUp" (exec "uwsm app -- brightnessctl s 5%+"))
      (bind "XF86MonBrightnessDown" (exec "uwsm app -- brightnessctl s 5%-"))
      (bind "XF86AudioRaiseVolume" (exec "uwsm app -- wpctl set-volume @DEFAULT_SINK@ 5%+"))
      (bind "XF86AudioLowerVolume" (exec "uwsm app -- wpctl set-volume @DEFAULT_SINK@ 5%-"))
      (bind "XF86AudioMute" (exec "uwsm app -- wpctl set-mute @DEFAULT_SINK@ toggle"))
      {
        _args = [
          "XF86AudioPlay"
          (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"uwsm app -- playerctl -p spotify play-pause\")")
          {locked = true;}
        ];
      }
      # (bind "XF86AudioPlay" (exec "uwsm app -- playerctl -p spotify play-pause") "{locked = true}")
    ];
    submaps.main.settings = {
      bind = [
        (bind "SHIFT + F" (fs "fullscreen"))
        (bind "X" "hl.dsp.window.close()")
        (bind "SHIFT + SPACE" "hl.dsp.window.float({})")
        (bind "H" ''hl.dsp.layout("focus l")'')
        (bind "L" ''hl.dsp.layout("focus r")'')
        (bind "K" (mvwfs "u"))
        (bind "J" (mvwfs "d"))
        (bind "mouse_up" (mvwfs "l"))
        (bind "mouse_down" (mvwfs "r"))
        (bind "mouse_left" (mvwfs "u"))
        (bind "mouse_right" (mvwfs "d"))
        (bind "SHIFT + H" (mvwddr "l"))
        (bind "SHIFT + L" (mvwddr "r"))
        (bind "SHIFT + K" (mvwddr "u"))
        (bind "SHIFT + J" (mvwddr "d"))
        (bind "SLASH" ''hl.dsp.layout("colresize +conf")'')
        (bind "1" (mvws "1"))
        (bind "2" (mvws "2"))
        (bind "3" (mvws "3"))
        (bind "4" (mvws "4"))
        (bind "5" (mvws "5"))
        (bind "6" (mvws "6"))
        (bind "7" (mvws "7"))
        (bind "8" (mvws "8"))
        (bind "9" (mvws "9"))
        (bind "0" (mvws "10"))
        (bind "SHIFT + 1" (mvwd "1"))
        (bind "SHIFT + 2" (mvwd "2"))
        (bind "SHIFT + 3" (mvwd "3"))
        (bind "SHIFT + 4" (mvwd "4"))
        (bind "SHIFT + 5" (mvwd "5"))
        (bind "SHIFT + 6" (mvwd "6"))
        (bind "SHIFT + 7" (mvwd "7"))
        (bind "SHIFT + 8" (mvwd "8"))
        (bind "SHIFT + 9" (mvwd "9"))
        (bind "SHIFT + 0" (mvwd "10"))
        (bind "T" (exec "uwsm app -- foot"))
        (bind "T" (submap "reset"))
        (bind "U" (exec ''wl-kbptr -o modes=bisect''))
        (bind "U" (submap "reset"))
        (bind "F" (exec ''wl-kbptr -o modes=floating,click -o mode_floating.source=detect''))
        (bind "F" (submap "reset"))
        (bind "W" (exec "hyprctl switchxkblayout all 0 && uwsm app -- fuzzel"))
        (bind "W" (submap "reset"))
        (bind "P" (exec "tessen"))
        (bind "P" (submap "reset"))
        (bind "Y" (exec "sleep 1 && uwsm app -- flameshot gui"))
        (bind "Y" (submap "reset"))
        (bind "O" (exec "uwsm app -- swaync-client -t"))
        (bind "SHIFT + V" (exec "uwsm app -- cliphist-fuzzel-img"))
        (bind "SHIFT + V" (submap "reset"))
        (bind "SHIFT + P" (exec "uwsm app -- hyprpicker -a"))
        (bind "SHIFT + P" (submap "reset"))
        (bind "SHIFT + B" (exec "uwsm app -- vaultsearch --fuzzel"))
        (bind "SHIFT + B" (submap "reset"))
        (bind "R" (submap "resize"))
        (bind "V" (exec "uwsm app -- hide_all"))
        (bind "escape" (submap "reset"))
        (bind "S" (exec (lib.getExe (mkMenu [
          {
            key = "t";
            desc = "Mails";
            cmd = "hyprctl 'dispatch hl.dsp.workspace.toggle_special(\"th\")'";
          }
          {
            key = "s";
            desc = "Spotify";
            cmd = "hyprctl 'dispatch hl.dsp.workspace.toggle_special(\"sp\")'";
          }
          {
            key = "q";
            desc = "Torrents";
            cmd = "hyprctl 'dispatch hl.dsp.workspace.toggle_special(\"qb\")'";
          }
          {
            key = "i";
            desc = "Temp text";
            cmd = "hyprctl 'dispatch hl.dsp.workspace.toggle_special(\"txtbuff\")'";
          }
        ]))))
        (bind "S" (submap "reset"))
        (bind "Z" (exec (lib.getExe (mkMenu [
          {
            key = "t";
            desc = "Telegram";
            cmd = "hyprctl 'dispatch hl.dsp.focus({window = \"class:org.telegram.desktop\"})'";
          }
          {
            key = "d";
            desc = "Discord";
            cmd = "hyprctl 'dispatch hl.dsp.focus({window = \"class:vesktop\"})'";
          }
          {
            key = "s";
            desc = "Slack";
            cmd = "hyprctl 'dispatch hl.dsp.focus({window = \"class:slack\"})'";
          }
          {
            key = "m";
            desc = "Mattermost";
            cmd = "hyprctl 'dispatch hl.dsp.focus({window = \"class:Mattermost.Desktop\"})'";
          }
        ]))))
        (bind "Z" (submap "reset"))
        (bind "M" (exec (lib.getExe (mkMenu [
          {
            key = "w";
            desc = "Connect to Wi-Fi";
            cmd = "uwsm app -- device-manager wifi";
          }
          {
            key = "u";
            desc = "Unmount devices";
            cmd = "uwsm app -- device-manager unmount";
          }
          {
            key = "m";
            desc = "Play media";
            cmd = "uwsm app -- medialist";
          }
          {
            key = "b";
            desc = "Bluetooth devices";
            cmd = "uwsm app -- device-manager bt";
          }
        ]))))
        (bind "M" (submap "reset"))
        (bind "Q" (exec (lib.getExe (mkMenu [
          {
            key = "q";
            desc = "Shutdown";
            cmd = "systemctl poweroff";
          }
          {
            key = "r";
            desc = "Reboot";
            cmd = "systemctl reboot";
          }
          {
            key = "l";
            desc = "Lock";
            cmd = "hyprctl switchxkblayout all 0 && uwsm app -- hyprlock";
          }
          {
            key = "L";
            desc = "Logout";
            cmd = "loginctl terminate-user $USER";
          }
          {
            key = "b";
            desc = "Reset Quickshell";
            cmd = "quickshell kill --path /home/hattivatt/.config/quickshell/main ; uwsm app -- quickshell --config /home/hattivatt/.config/quickshell/main";
          }
          {
            key = "p";
            desc = "Pause pomodoro";
            cmd = "uwsm app -- tmt toggle-pause";
          }
          {
            key = "f";
            desc = "Kill wl-kbptr";
            cmd = "killall wl-kbptr";
          }
        ]))))
        (bind "Q" (submap "reset"))
        (bind "SUPER" (submap "reset"))
        (bind "SUPER_L" (submap "reset"))
      ];
    };
    submaps.resize.settings = {
      bind = [
        (bind "SHIFT + H" (mvwfs "l"))
        (bind "SHIFT + L" (mvwfs "r"))
        (bind "SHIFT + K" (mvwfs "u"))
        (bind "SHIFT + J" (mvwfs "d"))
        (bind "escape" (submap "reset"))
        (bind "mouse:273" "hl.dsp.window.resize()")
        (bind "L" ''hl.dsp.layout("colresize +conf")'')
        (bind "H" ''hl.dsp.layout("colresize -conf")'')
      ];
    };
  };
}

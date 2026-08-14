{ inputs, config, ... }:
{
  flake.modules.nixos.hyprland =
  {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
    security.pam.services.hyprlock.enable = true;
  };
  flake.modules.homeManager.hyprland =
  { osConfig ? null, pkgs, lib, config, ... }:
  {
    xdg.configFile."uwsm/env" = lib.mkIf (osConfig != null) {
      source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
    };
    home.packages = with pkgs; [
      hyprpicker
      hyprland-per-window-layout
      hyprsysteminfo
    ];
    systemd.user.services = {
      change_wp = {
        Unit.Description = "Change wallpaper script";
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.local.change_wp}/bin/change_wp";
        };
      };
    };
    systemd.user.timers = {
      change_wp = {
        Unit = {
          Description = "Run change_wp script every 10 minutes";
          Requires = "change_wp.service";
        };
        Timer = {
          OnCalendar = "*:0/10";
          Unit = "change_wp.service";
        };
        Install.WantedBy = ["timers.target"];
      };
    };
    catppuccin.hyprland.enable = true;
    wayland.windowManager.hyprland = lib.mkMerge [
        (lib.mkIf (osConfig != null) {
          package = pkgs.hyprland;
          portalPackage = pkgs.xdg-desktop-portal-hyprland;
        })
        (lib.mkIf (osConfig == null) {
          package =  null;
          portalPackage = null;
        })
        {
        enable = true;
        configType = "lua";
        systemd.enable = false;
        settings = {
          config = {
            scrolling = {
              column_width = 0.5;
              focus_fit_method = 1;
              fullscreen_on_one_column = true;
              explicit_column_widths = "0.5, 0.98";
              wrap_focus = true;
            };
            input = {
              kb_layout = "uni_orto,uni_orto";
              kb_variant = "unieng,unirus";
              kb_options = "grp:caps_toggle,grp_led:caps";
              follow_mouse = 2;
              touchpad = {
                  natural_scroll = false;
                  tap_to_click = true;
              };
              sensitivity = 0;
            };
            general = {
              gaps_in = 2;
              gaps_out = 5;
              layout = "scrolling";
              allow_tearing = false;
            };
            cursor = {
              no_warps = true;
              hide_on_key_press = true;
              inactive_timeout = 10;
            };
            animations = {
              enabled = true;
              bezier = [ "myBezier, 0.05, 0.9, 0.1, 1.05" ];
              animation = [
                "windows, 1, 7, myBezier"
                "windowsOut, 1, 7, default, popin 80%"
                "border, 1, 10, default"
                "borderangle, 1, 8, default"
                "fade, 1, 7, default"
                "workspaces, 1, 6, default"
                "specialWorkspace, 1, 6, default, fade"
              ];
            };
          };
        };
      }
    ];
    services.hyprpolkitagent = lib.mkMerge [
      (lib.mkIf (osConfig != null) {
        enable = true;
      })
      (lib.mkIf (osConfig == null) {
        enable = false;
      })
    ];
    imports = [
      ./_parts/hyprlock.nix
      ./_parts/autostart.nix
      ./_parts/window_rules.nix
      ./_parts/keybindings.nix
      ./_parts/hyprland-autoname-workspaces.nix
    ];
  };
}

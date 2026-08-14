{
  flake.modules.homeManager.wl-kbptr =
  { pkgs, ... }:
  let
    ini = pkgs.formats.ini {};
  in
  {
    home.packages = with pkgs; [
      wl-kbptr
    ];
    xdg.configFile."wl-kbptr/config".source = ini.generate "config" {
      general = {
        home_row_keys = "";
        modes = "tile,bisect";
        cancellation_status_code = 0;
      };
      mode_tile = {
        label_color = "#fffd";
        label_select_color = "#fd0d";
        unselectable_bg_color = "#2226";
        selectable_bg_color = "#0304";
        selectable_border_color = "#040c";
        label_font_family = "sans-serif";
        label_font_size = "8 50% 100";
        label_symbols = "abcdefghijklmnopqrstuvwxyz";
      };
      mode_floating = {
        source = "stdin";
        label_color = "#cdd6f4";
        label_select_color = "#f38ba8";
        unselectable_bg_color = "#2226";
        selectable_bg_color = "#313244cc";
        selectable_border_color = "#f38ba8";
        label_font_family = "sans-serif";
        label_font_size = "25 50% 1000";
        label_symbols = "abcdefghijklmnopqrstuvwxyz";
      };
      mode_bisect = {
        label_color = "#cdd6f4";
        label_font_size = 20;
        label_font_family = "sans-serif";
        label_padding = 12;
        pointer_size = 20;
        pointer_color = "#e22d";
        unselectable_bg_color = "#2226";
        even_area_bg_color = "#7f849c80";
        even_area_border_color = "#eba0ac";
        odd_area_bg_color = "#31324480";
        odd_area_border_color = "#f38ba8";
        history_border_color = "#3339";
      };
      mode_split = {
        pointer_size = 20;
        pointer_color = "#e22d";
        bg_color = "#2226";
        area_bg_color = "#11111188";
        vertical_color = "#8888ffcc";
        horizontal_color = "#008800cc";
        history_border_color = "#3339";
      };
      mode_click.button = "left";
    };
  };
}

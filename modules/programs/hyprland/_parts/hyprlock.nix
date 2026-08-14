{ pkgs, lib, osConfig ? null, ... }:
{
  programs.hyprlock = lib.mkMerge [
    {
      enable = true;
      settings = {
        background = {
            path = "/home/hattivatt/Pictures/lockscreen.png";
            blur_passes = 0;
            blur_size = 7;
            noise = 0.0117;
            contrast = 0.8916;
            brightness = 0.8172;
            vibrancy = 0.1696;
            vibrancy_darkness = 0.0;
        };
      };
    }
    (lib.mkIf (osConfig != null) {
      package = pkgs.hyprlock;
    })
    (lib.mkIf (osConfig == null) {
      package = pkgs.emptyDirectory;
    })
  ];
}

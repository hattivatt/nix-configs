{
  flake.modules.homeManager.yadisk =
  { pkgs, ... }:
  {
    home.packages = with pkgs; [
      yandex-disk
    ];
    xdg.configFile."yandex-disk/config.cfg".text = ''
      auth="/home/hattivatt/.config/yandex-disk/passwd"
      dir="/home/hattivatt/Yandex.Disk"
      proxy="no"
    '';
  };
}

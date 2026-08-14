{
  flake.modules.homeManager.pass =
  { pkgs, config, ... }:
  let
    kv = pkgs.formats.keyValue {};
  in
  {
    home.packages = with pkgs; [
      tessen
    ];
    xdg.configFile."tessen/config".source = kv.generate "config" {
      pass_backend = ''"pass"'';
      dmenu_backend = ''"fuzzel"'';
    };
    programs.password-store = {
      enable = true;
      settings = {
          PASSWORD_STORE_DIR = "${config.xdg.dataHome}/pass";
      };
    };
  };
}

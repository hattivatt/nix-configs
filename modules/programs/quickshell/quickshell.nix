{
  flake.modules.homeManager.quickshell =
  { pkgs, lib, osConfig ? null, ... }:
  {
    programs.quickshell = lib.mkMerge [
      {
        enable = true;
        activeConfig = "main";
        configs.main = ./configs;
      }
      (lib.mkIf (osConfig != null) {
        package = pkgs.quickshell;
      })
      (lib.mkIf (osConfig == null) {
        package = pkgs.emptyDirectory;
      })
    ];
  };
}

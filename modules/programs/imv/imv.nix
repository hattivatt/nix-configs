{
  flake.modules.homeManager.imv =
  { lib, pkgs, osConfig ? null, ... }:
  {
    programs.imv = lib.mkMerge [
      {
        enable = true;
        settings = {
          options = {
            suppress_default_binds = false;
            scaling_mode = "full";
          };
        };
      }
      (lib.mkIf (osConfig != null) {
        package = pkgs.imv;
      })
      (lib.mkIf (osConfig == null) {
        package = pkgs.emptyDirectory;
      })
    ];
  };
}

{
  flake.modules.nixos.server-apps =
  { pkgs, ... }:
  {
    environment.systemPackages = with pkgs; [
    ];
  };
  flake.modules.homeManager.server-apps =
  { pkgs, config, ... }:
  {
    home.packages = with pkgs; [
      net-tools
      devenv
    ];
  };
}

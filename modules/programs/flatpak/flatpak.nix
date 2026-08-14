{
  flake.modules.nixos.flatpak =
  { pkgs, ... }:
  {
    services.flatpak.enable = true;
    environment.systemPackages = with pkgs; [
      flatpak
    ];
  };
  flake.modules.homeManager.flatpak =
  { pkgs, ... }:
  {
    home.packages = with pkgs; [
      flatpak
    ];
  };
}

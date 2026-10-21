{

  flake.modules.nixos.networkmanager =
  { pkgs, ... }:
  {
    networking.networkmanager.enable = true;
    networking.wireless.enable = true;
    networking.networkmanager.plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };
}

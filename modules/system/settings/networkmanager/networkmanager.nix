{

  flake.modules.nixos.networkmanager = {
    networking.networkmanager.enable = true;
    networking.wireless.enable = true;
  };
}

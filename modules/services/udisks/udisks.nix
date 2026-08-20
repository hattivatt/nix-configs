{
  flake.modules.nixos.udisks = {
    services.udisks2.enable = true;
  };
  flake.modules.homeManager.udisks = {
    services.udiskie = {
        enable = true;
    };
  };
}

{
  flake.modules.nixos.systemd-boot = {
    boot.loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 5;
    };
  };
}

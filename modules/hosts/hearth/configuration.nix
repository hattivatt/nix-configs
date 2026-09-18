{ inputs, ... }:
{
  flake.modules.nixos.hearth =
  { pkgs, ... }:
  {
    imports = with inputs.self.modules.nixos; [
      system-server
      systemd-boot
      preservation
    ];
    boot = {
      kernel.sysctl = {
        "vm.swappiness" = 180;
      };
    };
    environment.etc."machine-id".text = "159215926431405f8d36f0817ff2dac9";
    zramSwap.enable = true;
    programs.gnupg.agent = {
      enable = true;
      pinentryPackage = with pkgs; pinentry-tty;
    };
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    networking.nftables.enable = true;
    security.sudo = {
      wheelNeedsPassword = false;
    };
  };
}

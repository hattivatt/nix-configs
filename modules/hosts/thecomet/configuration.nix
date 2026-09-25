{ inputs, ... }:
{
  flake.modules.nixos.thecomet =
  { pkgs, inputs, ... }:
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
    sops = {
      defaultSopsFile = "${inputs.secrets}/server.yaml";
    };
    time.timeZone = "Asia/Ho_Chi_Minh";
    services.qemuGuest.enable = true;
    networking.nftables.enable = true;
    security.sudo = {
      wheelNeedsPassword = false;
    };
    networking = {
      hostName = "thecomet";
      useNetworkd = true;
      usePredictableInterfaceNames = false; # оставить eth0, как сейчас на Debian
    };
    systemd.network.networks."10-eth0" = {
      matchConfig.Name = "eth0";
      address = [ "203.25.119.37/24" "2403:2c81:2000:2143::a/64" ];
      routes = [
        { routeConfig = { Gateway = "203.25.119.1"; }; }
        { routeConfig = { Gateway = "2403:2c81:2000::1"; GatewayOnLink = true; }; }
      ];
      networkConfig.IPv6AcceptRA = false;
    };
  };
}

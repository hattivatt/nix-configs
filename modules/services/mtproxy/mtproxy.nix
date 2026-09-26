{
  flake.modules.nixos.mtproxy =
  { config, lib, pkgs, ... }:
  {
    sops.secrets."mtproxy/my_user" = { };
    sops.templates."mtproxy/config.py" = {
      mode = "0440";
      group = "mtproxy";
      restartUnits = [ "mtprotoproxy.service" ];
      content = ''
        PORT = 3256
        SECURE_ONLY = True
        USERS = {"me": "${config.sops.placeholder."mtproxy/my_user"}"}
      '';
    };
    users.groups.mtproxy = { };
    services.mtprotoproxy.enable = true;
    networking.firewall.allowedTCPPorts = [ 3256 ];
    systemd.services.mtprotoproxy.serviceConfig = {
      ExecStart = lib.mkForce "${pkgs.mtprotoproxy}/bin/mtprotoproxy ${config.sops.templates."mtproxy/config.py".path}";
      SupplementaryGroups = [ "mtproxy" ];
    };
  };
}

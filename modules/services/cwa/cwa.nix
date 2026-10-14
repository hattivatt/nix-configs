{
  flake.modules.nixos.cwa =
  { pkgs, config, ... }:
  {
    sops.secrets.hardcover_token = {
      restartUnits = [ "calibre-web-automated.service" ];
    };

    sops.templates."cwa.env" = {
      content = ''
        HARDCOVER_TOKEN=${config.sops.placeholder.hardcover_token}
      '';
    };
    services.calibre-web-automated = {
      enable = true;
      dataDir = "calibre-web";
      listen.port = 8083;
      options = {
        calibreLibrary = "/var/lib/calibre-library";
        enableBookUploading = true;
        enableBookConversion = true;
      };
    };
    systemd.services.calibre-web-automated.serviceConfig.EnvironmentFile = [
      config.sops.templates."cwa.env".path
    ];
  };
}

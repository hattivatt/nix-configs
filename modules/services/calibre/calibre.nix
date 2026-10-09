{
  flake.modules.nixos.calibre =
  { pkgs, config, ... }:
  {
    sops.secrets.hardcover_token = {
      restartUnits = [ "calibre-web.service" ];
    };

    sops.templates."calibre-web.env" = {
      content = ''
        HARDCOVER_TOKEN=${config.sops.placeholder.hardcover_token}
      '';
    };
    services.calibre-web = {
      enable = true;
      options = {
        calibreLibrary = "/var/lib/calibre-library";
        enableBookUploading = true;
        enableBookConversion = true;
      };
      package = pkgs.calibre-web.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          cp ${./metadata-providers/hardcover.py} \
            src/calibreweb/cps/metadata_provider/hardcover.py
        '';
      });
    };
    systemd.tmpfiles.rules = [
      "d /var/lib/calibre-library 0750 calibre-web calibre-web -"
    ];
    systemd.services.calibre-web.serviceConfig.EnvironmentFile = [
      config.sops.templates."calibre-web.env".path
    ];
    environment.systemPackages = [ pkgs.calibre ];
  };
}

{
  flake.modules.nixos.koinsight =
  { config, lib, ... }:
  let
    cfg = config.services.koinsight;

    container = "koinsight";
  in
  {
    options.services.koinsight = {
      enable = lib.mkEnableOption "KoInsight, a KOReader reading stats dashboard and progress sync server";

      image = lib.mkOption {
        type = lib.types.str;
        default = "ghcr.io/ko-insight/koinsight:latest";
        description = "Docker image for the KoInsight application.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 3000;
        description = "Host port the web interface is published on.";
      };

      bindAddress = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = ''
          Host address the web interface is published on. Keep the loopback
          default when a reverse proxy serves KoInsight.
        '';
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open the host port in the firewall.";
      };

      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/koinsight";
        description = ''
          Directory holding the KoInsight data, such as uploaded statistics
          databases and cover images.
        '';
      };

      maxFileSizeMB = lib.mkOption {
        type = lib.types.ints.positive;
        default = 100;
        description = "Maximum size in megabytes of an uploaded file.";
      };

      extraEnvironment = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Extra environment variables for the application container.";
      };
    };

    config = lib.mkIf cfg.enable {
      virtualisation.docker.enable = lib.mkDefault true;
      virtualisation.oci-containers.backend = lib.mkDefault "docker";

      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 0755 root root -"
      ];

      networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

      virtualisation.oci-containers.containers.${container} = {
        image = cfg.image;
        environment = {
          HOSTNAME = "0.0.0.0";
          PORT = "3000";
          DATA_PATH = "/app/data";
          MAX_FILE_SIZE_MB = toString cfg.maxFileSizeMB;
        } // cfg.extraEnvironment;
        volumes = [ "${cfg.dataDir}:/app/data" ];
        ports = [ "${cfg.bindAddress}:${toString cfg.port}:3000" ];
      };
    };
  };
}

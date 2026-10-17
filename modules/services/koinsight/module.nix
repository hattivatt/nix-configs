# KoInsight — native NixOS service module (dendritic flake-parts style).
#
# Replaces the previous docker/oci-containers module. Drop-in option names are
# preserved (enable/port/bindAddress/openFirewall/dataDir/maxFileSizeMB/
# extraEnvironment); the docker-only `image` option is intentionally gone.
#
# The module is inputs-free and only takes `{ config, lib, pkgs, ... }`, so it
# can be imported either through the flake-parts `import-tree` (as
# `flake.modules.nixos.koinsight`) or directly as a NixOS module.
{
  flake.modules.nixos.koinsight =
    { config, lib, pkgs, ... }:
    let
      cfg = config.services.koinsight;

      # Absolute path -> use as-is (tmpfiles rule); bare name -> /var/lib/<name>
      # (systemd StateDirectory). Mirrors the CWA module's handling.
      dataDir =
        if lib.hasPrefix "/" (toString cfg.dataDir) then toString cfg.dataDir else "/var/lib/${cfg.dataDir}";

      serviceEnv = {
        NODE_ENV = "production";
        PORT = toString cfg.port;
        # The app binds this address directly (no container port mapping);
        # "::" is accepted for dual-stack/IPv6 listeners.
        HOSTNAME = cfg.bindAddress;
        DATA_PATH = dataDir;
        MAX_FILE_SIZE_MB = toString cfg.maxFileSizeMB;
      } // cfg.extraEnvironment;

      hardening = {
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateIPC = true;
        ProtectHostname = true;
        ProtectClock = true;
        ProtectKernelTunables = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        LockPersonality = true;
        RestrictSUIDSGID = true;
        ProtectHome = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        RestrictNamespaces = true;
        RemoveIPC = true;
        CapabilityBoundingSet = "";
        AmbientCapabilities = "";
        ProtectKernelModules = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
          "AF_NETLINK"
        ];
        # NOTE: MemoryDenyWriteExecute is deliberately omitted — V8's JIT needs
        # writable-then-executable memory, which that setting forbids.
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];
      };

      stateDirectory = lib.optionalAttrs (!(lib.hasPrefix "/" (toString cfg.dataDir))) {
        StateDirectory = cfg.dataDir;
      };
    in
    {
      options.services.koinsight = {
        enable = lib.mkEnableOption "KoInsight, a KOReader reading stats dashboard and progress sync server";

        package = lib.mkPackageOption pkgs [ "local" "koinsight" ] { };

        port = lib.mkOption {
          type = lib.types.port;
          default = 3000;
          description = ''
            TCP port the web interface listens on (passed to the app as
            {env}`PORT`). When a reverse proxy serves KoInsight, this is the
            proxy's upstream port.
          '';
        };

        bindAddress = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1";
          description = ''
            Address the web interface binds to (passed to the app as
            {env}`HOSTNAME`; use `"::"` for a dual-stack/IPv6 listener). Keep the
            loopback default when a reverse proxy serves KoInsight.
          '';
        };

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Open {option}`port` in the firewall.";
        };

        dataDir = lib.mkOption {
          # The previous docker module used `lib.types.path`, which in current
          # nixpkgs rejects relative names; `types.str` (as in the CWA module)
          # keeps every existing absolute value working byte-for-byte and also
          # allows the `/var/lib/<name>` shorthand below.
          type = lib.types.str;
          default = "/var/lib/koinsight";
          description = ''
            Directory holding the KoInsight data: the SQLite databases
            ({file}`prod.sqlite3`), {file}`covers/` and uploaded statistics
            databases. Either an absolute path or a directory name below
            {file}`/var/lib`.
          '';
        };

        maxFileSizeMB = lib.mkOption {
          type = lib.types.ints.positive;
          default = 100;
          description = "Maximum size in megabytes of an uploaded file (passed to the app as {env}`MAX_FILE_SIZE_MB`).";
        };

        extraEnvironment = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = ''
            Extra environment variables for the service. Use this for optional
            knobs such as the OpenAI integration, e.g.
            `{ OPENAI_API_KEY = "\${config.sops.placeholder.openai_api_key}"; }`
            or via an {env}`EnvironmentFile` (see the site config).
          '';
        };

        user = lib.mkOption {
          type = lib.types.str;
          default = "koinsight";
          description = "User account under which KoInsight runs.";
        };

        group = lib.mkOption {
          type = lib.types.str;
          default = "koinsight";
          description = "Group account under which KoInsight runs.";
        };
      };

      config = lib.mkIf cfg.enable {
        systemd.tmpfiles.settings."10-koinsight" = lib.optionalAttrs (lib.hasPrefix "/" (toString cfg.dataDir)) {
          ${dataDir}.d = {
            inherit (cfg) user group;
            mode = "0750";
          };
        };

        systemd.services.koinsight = {
          description = "KoInsight — KOReader reading statistics server";
          documentation = [ "https://github.com/hattivatt/KoInsight" ];
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          environment = serviceEnv;

          serviceConfig = hardening // {
            Type = "simple";
            User = cfg.user;
            Group = cfg.group;
            WorkingDirectory = dataDir;

            # The wrapper still carries `NODE_ENV=production` and node on PATH;
            # the module sets every relevant variable explicitly above.
            ExecStart = "${cfg.package}/bin/koinsight";
            Restart = "on-failure";

            # Data lives outside the read-only store; grant the writable paths.
            ReadWritePaths = lib.optional (lib.hasPrefix "/" (toString cfg.dataDir)) dataDir;
          } // stateDirectory;
        };

        networking.firewall = lib.mkIf cfg.openFirewall {
          allowedTCPPorts = [ cfg.port ];
        };

        users.users = lib.mkIf (cfg.user == "koinsight") {
          koinsight = {
            isSystemUser = true;
            group = cfg.group;
            home = dataDir;
            description = "KoInsight service account";
          };
        };

        users.groups = lib.mkIf (cfg.group == "koinsight") {
          koinsight = { };
        };
      };

      meta.maintainers = [ ];
    };
}

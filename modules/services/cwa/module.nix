{
  flake.modules.nixos.cwa =
    { config, lib, pkgs, ... }:
    let
      cfg = config.services.calibre-web-automated;

      dataDir = if lib.hasPrefix "/" cfg.dataDir then cfg.dataDir else "/var/lib/${cfg.dataDir}";

      appDb = "${dataDir}/app.db";
      gdriveDb = "${dataDir}/gdrive.db";

      cacheDir = "/var/cache/calibre-web-automated";

      defaultLibraryDir = "/var/lib/calibre-library";
      libraryDir =
        if cfg.options.calibreLibrary != null then toString cfg.options.calibreLibrary else defaultLibraryDir;

      sqlStr = s: "'" + lib.replaceStrings [ "'" ] [ "''" ] s + "'";

      settings = lib.concatStringsSep ", " (
        [
          "config_uploading = ${if cfg.options.enableBookUploading then "1" else "0"}"
          "config_allow_reverse_proxy_header_login = ${
            if cfg.options.reverseProxyAuth.enable then "1" else "0"
          }"
          "config_reverse_proxy_login_header_name = ${sqlStr cfg.options.reverseProxyAuth.header}"
        ]
        ++ lib.optional (
          cfg.options.calibreLibrary != null
        ) "config_calibre_dir = ${sqlStr (toString cfg.options.calibreLibrary)}"
        ++ lib.optionals cfg.options.enableBookConversion [
          "config_converterpath = ${sqlStr "${cfg.calibrePackage}/bin/ebook-convert"}"
          "config_binariesdir = ${sqlStr "${cfg.calibrePackage}/bin/"}"
        ]
        ++ lib.optional cfg.options.enableKepubify "config_kepubifypath = ${sqlStr "${pkgs.kepubify}/bin/kepubify"}"
        # unrar is unfree, so opt-in via options.rarPackage.
        ++ lib.optional (
          cfg.options.rarPackage != null
        ) "config_rarfile_location = ${sqlStr "${cfg.options.rarPackage}/bin/unrar"}"
      );

      serviceEnv =
        {
          CALIBRE_DBPATH = dataDir;
          HOME = dataDir;
          # Inert for CWA v4 (kept for upstream parity).
          CACHE_DIR = cacheDir;
          # CWA has no config_port column; port comes from here.
          CWA_PORT_OVERRIDE = toString cfg.listen.port;
          CWA_DB_PATH = dataDir;
          CWA_APP_DB_PATH = appDb;
          CWA_LIBRARY_DIR = libraryDir;
          CWA_CALIBREDB_PATH = "${cfg.calibrePackage}/bin/calibredb";
        }
        // cfg.environment;

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
        MemoryDenyWriteExecute = true;
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
        SystemCallFilter = [
          "~@obsolete"
          "~@privileged"
          "~@raw-io"
          "~@resources"
          "~@mount"
          "~@debug"
          "~@cpu-emulation"
        ];
      };

      readWritePaths =
        lib.optional (lib.hasPrefix "/" cfg.dataDir) dataDir
        ++ [ cfg.ingestDir ]
        ++ lib.optional (cfg.options.calibreLibrary != null) (toString cfg.options.calibreLibrary);

      stateDirectory = lib.optionalAttrs (!(lib.hasPrefix "/" cfg.dataDir)) {
        StateDirectory = cfg.dataDir;
      };

      dirsJson = "${dataDir}/dirs.json";

      preStart = pkgs.writeShellScript "calibre-web-automated-pre-start" (
        ''
          set -eu

          # 0. Fail loudly if the package does not provide the ingest entrypoint the
          #    module relies on.
          test -x ${lib.escapeShellArg "${cfg.package}/bin/cps"} \
            || { echo "calibre-web-automated: ${cfg.package}/bin/cps is missing; the package must provide it."; exit 1; }
        ''
        + lib.optionalString (cfg.enableIngest && cfg.enableIngestWatcher) ''
          test -x ${lib.escapeShellArg "${cfg.package}/bin/cwa-ingest"} \
            || { echo "calibre-web-automated: ${cfg.package}/bin/cwa-ingest is missing; the package must provide it (see module header)."; exit 1; }
        ''
        + ''
          # 1. First-run seeding + DB migration, ONLY when app.db is absent.
          #    CWA has no __RUN_MIGRATIONS_AND_EXIT; `-d` (dry-run updater) still runs
          #    ub.init_db(), creating/migrating app.db, then exits. Mirrors docker cwa-init.
          #    Skipped on subsequent starts to avoid CWA's noisy read-only-store scan.
          if [ ! -f ${lib.escapeShellArg appDb} ]; then
            CALIBRE_DBPATH=${lib.escapeShellArg dataDir} \
            CWA_PORT_OVERRIDE=${toString cfg.listen.port} \
              ${cfg.package}/bin/cps -p ${lib.escapeShellArg appDb} -g ${lib.escapeShellArg gdriveDb} -d
          fi

          # 2. Inject declarative settings (same idea/keys as the upstream module,
          #    minus config_port which CWA does not have). Idempotent, runs every start.
          ${pkgs.sqlite}/bin/sqlite3 ${lib.escapeShellArg appDb} "update settings set ${settings}"

          # 3. Validate the Calibre library (same check as upstream).
        ''
        + lib.optionalString (cfg.options.calibreLibrary != null) ''
          test -f ${lib.escapeShellArg "${toString cfg.options.calibreLibrary}/metadata.db"} \
            || { echo "Invalid Calibre library"; exit 1; }
        ''
        + ''
          # 4. CWA working directories (docker cwa-init equivalent).
          install -d -m 0750 \
            ${lib.escapeShellArg "${dataDir}/processed_books/converted"} \
            ${lib.escapeShellArg "${dataDir}/processed_books/imported"} \
            ${lib.escapeShellArg "${dataDir}/processed_books/failed"} \
            ${lib.escapeShellArg "${dataDir}/processed_books/fixed_originals"} \
            ${lib.escapeShellArg "${dataDir}/processed_books/duplicate_resolutions"} \
            ${lib.escapeShellArg "${dataDir}/log_archive"} \
            ${lib.escapeShellArg "${dataDir}/.cwa_conversion_tmp"} \
            ${lib.escapeShellArg cfg.ingestDir}

          # Calibre plugins live under $HOME/.config/calibre; skip on network shares,
          # where chown/ownership semantics are owned by the remote server.
          network_share_mode="$(printf '%s' "''${NETWORK_SHARE_MODE:-}" | tr '[:upper:]' '[:lower:]')"
          case "$network_share_mode" in
            1|true|yes|on) : ;;
            *) install -d -m 0750 ${lib.escapeShellArg "${dataDir}/.config/calibre/plugins"} ;;
          esac

          # 5. dirs.json — written at runtime so the manifest always reflects the
          #    current option values (and no jq is needed).
          printf '{"ingest_folder":"%s","calibre_library_dir":"%s","tmp_conversion_dir":"%s"}\n' \
            ${lib.escapeShellArg cfg.ingestDir} \
            ${lib.escapeShellArg libraryDir} \
            ${lib.escapeShellArg "${dataDir}/.cwa_conversion_tmp"} \
            > ${lib.escapeShellArg dirsJson}

          # 6. Files the docker init stages on first run.
          [ -f ${lib.escapeShellArg "${dataDir}/user_profiles.json"} ] \
            || echo '{}' > ${lib.escapeShellArg "${dataDir}/user_profiles.json"}
          [ -f ${lib.escapeShellArg "${dataDir}/client_secrets.json"} ] \
            || echo '{}' > ${lib.escapeShellArg "${dataDir}/client_secrets.json"}
        ''
      );
    in
    {
      options.services.calibre-web-automated = {
        enable = lib.mkEnableOption "Calibre-Web-Automated";

        package = lib.mkPackageOption pkgs [ "local" "calibre-web-automated" ] { };

        calibrePackage = lib.mkPackageOption pkgs "calibre" { };

        listen = {
          ip = lib.mkOption {
            type = lib.types.str;
            default = "::1";
            description = "IP address that Calibre-Web-Automated should listen on.";
          };

          port = lib.mkOption {
            type = lib.types.port;
            default = 8083;
            description = "Listen port for Calibre-Web-Automated (sets {env}`CWA_PORT_OVERRIDE`).";
          };
        };

        dataDir = lib.mkOption {
          type = lib.types.str;
          default = "calibre-web-automated";
          description = ''
            Where Calibre-Web-Automated stores its data (app.db, gdrive.db, cwa.db,
            dirs.json and the CWA working directories). Either an absolute path or a
            directory name below {file}`/var/lib`.
          '';
        };

        user = lib.mkOption {
          type = lib.types.str;
          default = "calibre-web-automated";
          description = "User account under which Calibre-Web-Automated runs.";
        };

        group = lib.mkOption {
          type = lib.types.str;
          default = "calibre-web-automated";
          description = "Group account under which Calibre-Web-Automated runs.";
        };

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Open ports in the firewall for the server.";
        };

        ingestDir = lib.mkOption {
          type = lib.types.str;
          default = "/var/lib/cwa-ingest";
          description = ''
            The ingest ("watch") folder; eBooks dropped here are imported (and, if
            enabled, converted) into the Calibre library.
          '';
        };

        enableIngest = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Master switch for the CWA ingest pipeline. The ingest service/timer is
            only created when **both** this and {option}`enableIngestWatcher` are
            {literal}`true`.
          '';
        };

        enableIngestWatcher = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Run the periodic systemd service/timer that performs ingest passes over
            {option}`ingestDir`.
          '';
        };

        environment = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = ''
            Extra environment variables injected into the service (and the ingest
            service).
          '';
        };

        options = {
          calibreLibrary = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = ''
              Path to the Calibre library. Must be writable by the service user
              (re-own/group-add if migrating from services.calibre-web); WAL is auto-disabled when metadata.db isn't writable.
            '';
          };

          enableBookConversion = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Configure the path to Calibre's {command}`ebook-convert` in the DB.";
          };

          enableKepubify = lib.mkEnableOption "kepub conversion support";

          rarPackage = lib.mkOption {
            type = lib.types.nullOr lib.types.package;
            default = null;
            description = ''
              Package whose {file}`bin/unrar` is registered as CWA's
              {file}`config_rarfile_location`. Note that {package}`unrar` is unfree,
              so selecting it requires {option}`nixpkgs.config.allowUnfree`.
            '';
          };

          enableBookUploading = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Allow books to be uploaded via the Calibre-Web-Automated UI.";
          };

          reverseProxyAuth = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Enable authorization using an auth proxy.";
            };

            header = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Auth proxy header name.";
            };
          };
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = lib.hasPrefix "/" cfg.ingestDir;
            message = "services.calibre-web-automated.ingestDir must be an absolute path.";
          }
        ];

        systemd.tmpfiles.settings."10-calibre-web-automated" =
          lib.optionalAttrs (lib.hasPrefix "/" cfg.dataDir) {
            ${dataDir}.d = {
              inherit (cfg) user group;
              mode = "0700";
            };
          }
          // {
            ${cfg.ingestDir}.d = {
              inherit (cfg) user group;
              mode = "0700";
            };
          };

        systemd.services.calibre-web-automated =
          {
            description = "Calibre-Web-Automated — web app with an automated ingest/convert pipeline";
            documentation = [ "https://github.com/crocodilestick/Calibre-Web-Automated/wiki" ];
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];

            path = [
              pkgs.coreutils
              pkgs.findutils
              pkgs.lsof
              cfg.calibrePackage
            ]
            ++ lib.optional cfg.options.enableKepubify pkgs.kepubify
            ++ lib.optional (cfg.options.rarPackage != null) cfg.options.rarPackage;

            environment = serviceEnv;

            serviceConfig = hardening // {
              Type = "simple";
              User = cfg.user;
              Group = cfg.group;
              WorkingDirectory = dataDir;

              ExecStartPre = preStart;
              ExecStart = "${cfg.package}/bin/cps -p ${appDb} -g ${gdriveDb} -i ${cfg.listen.ip}";
              Restart = "on-failure";

              CacheDirectory = "calibre-web-automated";
              CacheDirectoryMode = "0750";

              ReadWritePaths = readWritePaths;
            } // stateDirectory;
          };

        systemd.services.calibre-web-automated-ingest = lib.mkIf (cfg.enableIngest && cfg.enableIngestWatcher) {
          description = "Calibre-Web-Automated ingest pass";
          after = [ "calibre-web-automated.service" ];
          wants = [ "calibre-web-automated.service" ];

          path = [
            pkgs.coreutils
            pkgs.findutils
            pkgs.lsof
            cfg.calibrePackage
          ]
          ++ lib.optional cfg.options.enableKepubify pkgs.kepubify
          ++ lib.optional (cfg.options.rarPackage != null) cfg.options.rarPackage;

          environment = serviceEnv;

          serviceConfig = hardening // {
            Type = "oneshot";
            User = cfg.user;
            Group = cfg.group;
            WorkingDirectory = dataDir;

            ExecStart = "${cfg.package}/bin/cwa-ingest";
            Restart = "on-failure";
            RestartSec = "30s";

            ReadWritePaths = readWritePaths;
          } // stateDirectory;
        };

        systemd.timers.calibre-web-automated-ingest = lib.mkIf (cfg.enableIngest && cfg.enableIngestWatcher) {
          description = "Periodically run a Calibre-Web-Automated ingest pass";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            Unit = "calibre-web-automated-ingest.service";
            OnBootSec = "5m";
            OnUnitActiveSec = "2m";
          };
        };

        networking.firewall = lib.mkIf cfg.openFirewall {
          allowedTCPPorts = [ cfg.listen.port ];
        };

        users.users = lib.mkIf (cfg.user == "calibre-web-automated") {
          calibre-web-automated = {
            isSystemUser = true;
            group = cfg.group;
            home = dataDir;
            description = "Calibre-Web-Automated service account";
          };
        };

        users.groups = lib.mkIf (cfg.group == "calibre-web-automated") {
          calibre-web-automated = { };
        };
      };

      meta.maintainers = [ ];
    };
}

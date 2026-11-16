{
  flake.modules.nixos.campaign-bot =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services.campaign-bot;

      runtime = if cfg.profile == null then cfg.package else cfg.profile;

      yaml = pkgs.formats.yaml { };

      settingsFile = yaml.generate "campaign-bot.yaml" (
        lib.recursiveUpdate { data_dir = cfg.stateDir; } cfg.settings
      );

      stateUnderVarLib = lib.hasPrefix "/var/lib/" cfg.stateDir;

      foundryRoot = cfg.foundryData.root;
      foundryPaths = lib.optionals (foundryRoot != null) cfg.foundryData.paths;

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
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];
      };

      stateDirectory = lib.optionalAttrs stateUnderVarLib {
        StateDirectory = lib.removePrefix "/var/lib/" cfg.stateDir;
        StateDirectoryMode = "0750";
      };
    in
    {
      options.services.campaign-bot = {
        enable = lib.mkEnableOption "campaign-bot, a Discord bot that runs tabletop RPG campaigns";

        package = lib.mkPackageOption pkgs [ "local" "campaign-bot" ] { };

        profile = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "/nix/var/nix/profiles/campaign-bot";
          description = ''
            Nix profile the service runs campaign-bot from instead of
            {option}`package`. The unit then calls `<profile>/bin/campaign-bot`,
            so a release is deployed by switching the profile and restarting
            {command}`campaign-bot.service` (deploy-rs), without a NixOS rebuild
            or a new system generation, and {option}`package` is never evaluated.
            The profile keeps its own generations
            (`nix-env -p <profile> --rollback`) and is a GC root. It must exist
            before the unit starts, so run the first deploy before switching the
            system to this option. `null` keeps the store path of
            {option}`package` in the unit.
          '';
        };

        user = lib.mkOption {
          type = lib.types.str;
          default = "campaign-bot";
          description = "User account under which campaign-bot runs.";
        };

        group = lib.mkOption {
          type = lib.types.str;
          default = "campaign-bot";
          description = "Group account under which campaign-bot runs.";
        };

        stateDir = lib.mkOption {
          type = lib.types.path;
          default = "/var/lib/campaign-bot";
          apply = toString;
          description = ''
            Directory holding the bot data: {file}`campaigns/`, {file}`shared/`
            and the wiki repositories. It is the service working directory and the
            home of the service user.
          '';
        };

        environmentFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          example = "/run/secrets/campaign-bot.env";
          description = ''
            {env}`EnvironmentFile` with the secrets {env}`DISCORD_TOKEN`,
            {env}`OPENCODE_API_KEY` and {env}`FOUNDRY_PASSWORD`. The variable names
            can be changed through {option}`settings` (`discord.token_env`,
            `llm.api_key_env`).
          '';
        };

        foundryData = {
          root = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "/home/alice/.local/share/FoundryVTT";
            description = ''
              Foundry user data root on this host. When set, every directory from
              {option}`foundryData.paths` is bind-mounted read-write into the service at
              {file}`<stateDir>/foundry/<path>` and gets a POSIX ACL (plus a default
              ACL) granting the service user `rwX`, so the bot can rename files. Set
              `foundry.data_dir` in {file}`campaign.yaml` to the mounted `Data`
              directory, e.g. {file}`/var/lib/campaign-bot/foundry/v14/Data`.
            '';
          };

          paths = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [
              "v14/Data"
              "common"
            ];
            description = ''
              Directories under {option}`foundryData.root` to expose. Include the
              targets of symlinks inside `Data` (such as `common`) with the same
              relative layout, so the links resolve inside the service.
            '';
          };
        };

        settings = lib.mkOption {
          type = yaml.type;
          default = { };
          example = lib.literalExpression ''
            {
              llm = {
                model = "deepseek-v4.1-flash";
                max_steps = 12;
              };
            }
          '';
          description = ''
            Bot configuration rendered to YAML and passed through
            {env}`CAMPAIGN_BOT_CONFIG`. Merged recursively over
            `{ data_dir = stateDir; }`. Supported keys are `data_dir`,
            `llm.{base_url,model,api_key_env,max_steps,timeout_ms,history_messages,session_header,user_agent}`
            and `discord.token_env`.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = cfg.profile == null || lib.hasPrefix "/" cfg.profile;
            message = "services.campaign-bot.profile must be an absolute path";
          }
        ];

        systemd.tmpfiles.settings."10-campaign-bot" =
          lib.optionalAttrs (!stateUnderVarLib) {
            ${cfg.stateDir}.d = {
              inherit (cfg) user group;
              mode = "0750";
            };
          }
          // lib.listToAttrs (
            map (
              path:
              lib.nameValuePair "${foundryRoot}/${path}" {
                "A+".argument = "u:${cfg.user}:rwX,d:u:${cfg.user}:rwX";
              }
            ) foundryPaths
          );

        systemd.services.campaign-bot = {
          description = "campaign-bot Discord bot";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];

          environment = {
            CAMPAIGN_BOT_CONFIG = toString settingsFile;
            HOME = cfg.stateDir;
          };

          serviceConfig =
            hardening
            // {
              Type = "simple";
              User = cfg.user;
              Group = cfg.group;
              WorkingDirectory = cfg.stateDir;
              ExecStart = "${runtime}/bin/campaign-bot";
              EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
              Restart = "on-failure";
              RestartSec = 10;
              ReadWritePaths = [ cfg.stateDir ];
              BindPaths = map (path: "${foundryRoot}/${path}:${cfg.stateDir}/foundry/${path}") foundryPaths;
            }
            // stateDirectory;
        };

        users.users = lib.mkIf (cfg.user == "campaign-bot") {
          campaign-bot = {
            isSystemUser = true;
            group = cfg.group;
            home = cfg.stateDir;
            description = "campaign-bot service account";
          };
        };

        users.groups = lib.mkIf (cfg.group == "campaign-bot") {
          campaign-bot = { };
        };
      };
    };
}

{ inputs, ... }:
{
  flake.modules.nixos.agents =
  {
    nixpkgs.overlays = [ inputs.llm-agents.overlays.shared-nixpkgs ];
    nix.settings = {
      extra-substituters = [ "https://cache.numtide.com" ];
      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };
  };
  flake.modules.homeManager.agents =
  { config, pkgs, ... }:
  let
    opencode2 = pkgs.llm-agents.opencode2;

    opencode = pkgs.runCommand "opencode-${opencode2.version}" {
      meta = opencode2.meta // {
        mainProgram = "opencode";
      };
    } ''
      mkdir -p "$out/bin"
      ln -s ${opencode2}/bin/opencode2 "$out/bin/opencode"
    '';
    t3code = pkgs.llm-agents.t3code.override {
      providerPackages = [];
      t3code-unwrapped = pkgs.llm-agents.t3code.unwrapped.overrideAttrs (old: {
        preBuild = (old.preBuild or "") + ''
          cp .env.example .env
        '';
      });
    };
  in
  {
    sops = {
      secrets."agents/opencode" = { };
    };
    programs.opencode = {
      enable = true;
      package = opencode;
    };
    programs.pi-coding-agent = {
      enable = true;
      configDir = "${config.xdg.configHome}/pi/agent";
      package = pkgs.llm-agents.pi;
    };
    home.shellAliases = {
      pia = ''pi -p --model "opencode-go/deepseek-v4-flash"'';
    };
    home.file.".config/opencode/AGENTS.md".source = ./common/AGENTS.md;
    home.file.".config/pi/agent/AGENTS.md".source = ./common/AGENTS.md;
    home.packages = with pkgs; [
      t3code
      local.autolith
    ];
    programs.nushell.extraEnv = ''
      $env.OPENCODE_API_KEY = (open ${config.sops.secrets."agents/opencode".path} | str trim)
    '';
  };
  flake.modules.homeManager.agents-desktop =
  { inputs, pkgs, ... }:
  let
    t3code = pkgs.llm-agents.t3code.override {
      providerPackages = [];
      t3code-unwrapped = pkgs.llm-agents.t3code.unwrapped.overrideAttrs (old: {
        preBuild = (old.preBuild or "") + ''
          cp .env.example .env
        '';
      });
    };
  in
  {
    imports = with inputs.self.modules.homeManager; [
      agents
    ];
    home.packages = with pkgs; [
      t3code.desktop
    ];
  };
  flake.modules.homeManager.agents-server =
  { inputs, config, lib, pkgs, ... }:
  let
    t3code = pkgs.llm-agents.t3code.override {
      providerPackages = [];
      t3code-unwrapped = pkgs.llm-agents.t3code.unwrapped.overrideAttrs (old: {
        preBuild = (old.preBuild or "") + ''
          cp .env.example .env
        '';
      });
    };
  in
  {
    imports = with inputs.self.modules.homeManager; [
      agents
    ];
    sops.secrets."gh_token" = { };
    sops.templates."t3code.env".content = ''
      OPENCODE_API_KEY=${config.sops.placeholder."agents/opencode"}
      GH_TOKEN=${config.sops.placeholder."gh_token"}
    '';
    systemd.user.services.t3code = {
      Unit = {
        Description = "T3 Code server";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        ExecStart = "${t3code}/bin/t3 serve";
        EnvironmentFile = config.sops.templates."t3code.env".path;
        Restart = "on-failure";
        RestartSec = 5;

        Environment = [
          "T3CODE_CLOUDFLARED_PATH=${lib.getExe pkgs.cloudflared}"
          (
            "PATH="
            + lib.makeBinPath [
              pkgs.coreutils
              pkgs.git
              config.programs.opencode.package
              pkgs.llm-agents.pi
            ]
            + ":${config.home.homeDirectory}/.nix-profile/bin"
            + ":/etc/profiles/per-user/${config.home.username}/bin"
            + ":/run/current-system/sw/bin"
          )
        ];
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}

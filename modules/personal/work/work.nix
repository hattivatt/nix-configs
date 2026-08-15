{
  flake.modules.homeManager.work =
  { config, pkgs, ... }:
  {
    sops = {
      secrets."vcs/work_include" = { };
      secrets."vcs/work_content" = { };
      secrets."vcs/pass_helper" = { };
      secrets.tp_user = { };
      secrets.tp_proxy = { };
      secrets.vault_addr = { };

      templates.nushell-aliases = {
        content = ''
          alias tlog = tsh login --user=${config.sops.placeholder.tp_user} --proxy=${config.sops.placeholder.tp_proxy}:443
        '';
      };
    };
    home.packages = with pkgs; [
      local.teleport16
      openfortivpn
      fluxcd
      kubernetes-helm
    ];
    home.shellAliases = {
      vlog = "vault login -method=oidc role='default_user'";
      bkpw = "workbackup /home/hattivatt/.local/share/tombs/work.tomb /run/media/hattivatt/UD12/workbackups";
      wcn = "sudo openfortivpn --config /home/hattivatt/.config/openfortivpn/config --saml-login --pppd-use-peerdns=1";
      wcnr = "sudo openfortivpn --config /home/hattivatt/.config/openfortivpn/config-res --saml-login --pppd-use-peerdns=1";
    };
    programs.nushell = {
      enable = true;
      environmentVariables = {
        VAULT_SKIP_VERIFY = "true";
      };
      extraEnv = ''
        $env.VAULT_ADDR = (open ${config.sops.secrets.vault_addr.path} | str trim)
      '';
      extraConfig = ''
        # Functions
        def --env st [] {
            source /home/hattivatt/.tfenv.nu
        }
        source ${config.sops.templates.nushell-aliases.path}
      '';
    };
    programs.git = {
      includes = [
        { path = config.sops.secrets."vcs/work_include".path; }
      ];
    };
    xdg.configFile = {
      "pass-git-helper/git-pass-mapping.ini".source = config.lib.file.mkOutOfStoreSymlink config.sops.secrets."vcs/pass_helper".path;
    };
    imports = [
      ./_parts/openfortivpn.nix
      ./_parts/extraFiles.nix
    ];
  };
}

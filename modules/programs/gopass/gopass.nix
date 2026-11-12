{
  flake.modules.homeManager.gopass =
  { pkgs, config, ... }:
  let
    kv = pkgs.formats.keyValue {};
  in
  {
    sops.secrets.gopass-keyring = {
      sopsFile =
        (builtins.dirOf config.sops.defaultSopsFile)
        + "/keyring.sops";
      format = "binary";
      mode = "0400";
      path = "${config.xdg.configHome}/gopass/age/identities";
    };
    home.packages = with pkgs; [
      local.gopass
      (pkgs.symlinkJoin {
        name = "gopass-jsonapi-no-pass-store-dir";
        paths = [ pkgs.gopass-jsonapi ];
        nativeBuildInputs = [ pkgs.makeWrapper ];

        postBuild = ''
          wrapProgram $out/bin/gopass-jsonapi \
            --unset PASSWORD_STORE_DIR
        '';
      })
      tessen
      git-credential-gopass
      pinentry-qt
    ];
    xdg.configFile."tessen/config".source = kv.generate "config" {
      pass_backend = ''"gopass"'';
      dmenu_backend = ''"fuzzel"'';
    };
    xdg.configFile."gopass/config".text = ''
      [mounts]
        path = /home/hattivatt/.local/share/passage
      [recipients]
        hash = 52f4faa4c0314b06155c7bfd6447f41345bc74b89d1af4a1fadf4836884514f4
      [age]
        agent-timeout = 36000
        agent-enabled = true
    '';
    systemd.user.services.gopass-age-agent = {
      Unit = {
        After = [ "graphical-session.target" "sops-nix.service" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.local.gopass}/bin/gopass age agent start";
        ExecStartPost = "${pkgs.bash}/bin/bash -c 'until ${pkgs.local.gopass}/bin/gopass age agent status; do sleep 0.2; done'";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
    systemd.user.services.gopass-secret-service = {
      Unit = {
        Description = "gopass Secret Service";
        After = [ "graphical-session.target" "sops-nix.service" "gopass-age-agent.service" ];
        Wants = [ "gopass-age-agent.service" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.secrets";
        ExecStart = "${pkgs.local.gopass}/bin/gopass secret-service serve";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}

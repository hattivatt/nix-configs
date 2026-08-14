{
  flake.modules.homeManager.accounts =
  { pkgs, ... }:
  {
    programs = {
      khal.enable = true;
      pimsync.enable = true;
      khard.enable = true;
      w3m.enable = true;
      aerc = {
        enable = true;
        extraConfig = {
          general.unsafe-accounts-conf = true;
          hooks.mail-received = ''notify-send "New mail from $AERC_FROM_NAME" "$AERC_SUBJECT"'';
          filters = {
            "text/plain" = "colorize";
            "text/html" = "! w3m -I UTF-8 -T text/html";
          };
          viewer.show-images = true;
        };
      };
    };
    systemd.user.services = {
      calnotif = {
        Unit.Description = "Notifications for events from khal";
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.local.calnotif}/bin/calnotif";
        };
      };
    };
    systemd.user.timers = {
      calnotif = {
        Unit = {
          Description = "Run calnotif script every minute";
          Requires = "calnotif.service";
        };
        Timer = {
          OnCalendar = "*:*:00";
          AccuracySec = "1s";
          Unit = "calnotif.service";
          Persistent = true;
        };
        Install.WantedBy = ["timers.target"];
      };
    };
    imports = [
      ./_parts/contacts.nix
      ./_parts/calendars.nix
    ];
  };
}

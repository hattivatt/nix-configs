{
  flake.modules.homeManager.accounts =
  { inputs, pkgs, ... }:
  {
    accounts.email.maildirBasePath = ".local/share/mails";
    programs = {
      khal.enable = true;
      pimsync.enable = true;
      khard.enable = true;
      w3m.enable = true;
      mbsync = {
        enable = true;
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
      inputs.self.modules.homeManager.aerc
      inputs.self.modules.homeManager.afew
      inputs.self.modules.homeManager.notmuch
    ];
  };
}

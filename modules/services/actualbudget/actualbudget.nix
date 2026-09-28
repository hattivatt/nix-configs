{
  flake.modules.nixos.actualbudget =
  {
    users.users.actual = {
      isSystemUser = true;
      group = "actual";
      home = "/var/lib/actual";
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/actual/server-files 0700 actual actual -"
      "d /var/lib/actual/user-files 0700 actual actual -"
    ];

    users.groups.actual = {};
    services.actual = {
      enable = true;
      user = "actual";
      group = "actual";
      settings = {
        dataDir = "/var/lib/actual";
        port = 3000;
      };
    };
  };
}

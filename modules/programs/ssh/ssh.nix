{
  flake.modules.homeManager.ssh = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        thecomet = {
          hostName = "203.25.119.37";
          user = "hattivatt";
        };
        "*" = {
          AddKeysToAgent = "no";
          Compression = "no";
          ControlMaster = "no";
          ControlPath = "~/.ssh/master-%r@%n:%p";
          ControlPersist = "no";
          ForwardAgent = "no";
          HashKnownHosts = "no";
          ServerAliveCountMax = "3";
          ServerAliveInterval = "0";
          UserKnownHostsFile = "~/.ssh/known_hosts";
        };
      };
    };
  };
}

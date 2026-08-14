{
  flake.modules.homeManager.tundra =
  { pkgs, config, ... }:
  {
    systemd.user.services = {
      tundra = {
        Unit = {
          Description = "Tundra daemon";
          After = "network.target";
        };
        Install.WantedBy = ["default.target"];
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.flatpak}/bin/flatpak run moe.tundra.Tundra daemon";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    };
  };
}

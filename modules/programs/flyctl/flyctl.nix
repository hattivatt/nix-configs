{
  flake.modules.homeManager.flyctl =
  { pkgs, ... }:
  {
    home.packages = with pkgs; [
      flyctl
    ];
    xdg.configFile."flyio/fly.toml".text = ''
      # fly.toml app configuration file generated for hatibudget on 2023-11-01T13:13:30+05:30
      #
      # See https://fly.io/docs/reference/configuration/ for information about how to use this file.
      #

      app = "hatibudget"
      primary_region = "sin"

      [experimental]
        cmd = ["node", "--max-old-space-size=180", "app.js"]
        auto_rollback = true

      [build]
        image = "actualbudget/actual-server:latest"

      [env]
        PORT = "5006"
        TINI_SUBREAPER = "1"

      [[mounts]]
        source = "actual_data"
        destination = "/data"

      [[services]]
        protocol = "tcp"
        internal_port = 5006
        processes = ["app"]

        [[services.ports]]
          port = 80
          handlers = ["http"]
          force_https = true

        [[services.ports]]
          port = 443
          handlers = ["tls", "http"]
        [services.concurrency]
          type = "connections"
          hard_limit = 25
          soft_limit = 20

        [[services.tcp_checks]]
          interval = "15s"
          timeout = "2s"
          grace_period = "10s"
    '';
  };
}

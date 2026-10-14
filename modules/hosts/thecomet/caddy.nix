{
  flake.modules.nixos.thecomet =
  { config, ... }:
  {
    sops = {
      secrets.cf_token = { };
      secrets.koinsight_basic_auth = {
        owner = "caddy";
        group = "caddy";
        mode = "0400";
      };
    };
    services.caddy = {
      environmentFile = config.sops.secrets.cf_token.path;
      virtualHosts."*.hattivatt.fyi".extraConfig = ''
        tls {
            dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        }

        @foundryvtt host foundryvtt.hattivatt.fyi
        handle @foundryvtt {
          reverse_proxy localhost:30000
        }

        @actual host actual.hattivatt.fyi
        handle @actual {
          encode gzip zstd
          reverse_proxy localhost:3000
        }

        @syncthing host syncthing.hattivatt.fyi
        handle @syncthing {
          reverse_proxy 127.0.0.1:8384 {
              header_up Host localhost:8384
          }
        }

        @koinsight host koinsight.hattivatt.fyi
        handle @koinsight {
          basic_auth {
            import ${config.sops.secrets.koinsight_basic_auth.path}
          }
          reverse_proxy 127.0.0.1:3228
        }

        @calibre host calibre.hattivatt.fyi
        handle @calibre {
          reverse_proxy localhost:8083
        }

        @cwa host cwa.hattivatt.fyi
        handle @cwa {
          reverse_proxy localhost:8083
        }

        handle {
            abort
        }
      '';
    };
  };
}

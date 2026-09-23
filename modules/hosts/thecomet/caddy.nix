{
  flake.modules.nixos.thecomet =
  { config, ... }:
  {
    sops = {
      secrets.cf_token = { };
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

        @syncthing host syncthing.hattivatt.fyi
        handle @syncthing{
            reverse_proxy localhost:8384
        }

        handle {
            abort
        }
      '';
    };
  };
}

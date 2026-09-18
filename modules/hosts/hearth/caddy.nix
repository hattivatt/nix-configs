{
  flake.modules.nixos.hearth =
  {
    services.caddy = {
      acmeCA = "https://acme-staging-v02.api.letsencrypt.org/directory";
      virtualHosts."*.hattivatt.test".extraConfig = ''
        tls {
            dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        }

        @app host foundryvtt.hattivatt.test
        handle @foundryvtt {
            reverse_proxy localhost:30000
        }

        @api host syncthing.hattivatt.test
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

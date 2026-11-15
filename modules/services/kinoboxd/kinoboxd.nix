{
  flake.modules.nixos.kinoboxd =
    { config, ... }:
    {
      sops.secrets.kinoboxd_tmdb_token = {
        restartUnits = [ "kinoboxd.service" ];
      };

      sops.secrets.kinoboxd_password = {
        restartUnits = [ "kinoboxd.service" ];
      };

      sops.secrets.kinoboxd_hardcover_token = {
        restartUnits = [ "kinoboxd.service" ];
      };

      sops.secrets.kinoboxd_gb_api_key = {
        restartUnits = [ "kinoboxd.service" ];
      };
      sops.secrets.kinoboxd_steam_api_key = {
        restartUnits = [ "kinoboxd.service" ];
      };
      sops.templates."kinoboxd.env" = {
        content = ''
          TMDB_API_TOKEN=${config.sops.placeholder.kinoboxd_tmdb_token}
          HARDCOVER_API_TOKEN=${config.sops.placeholder.kinoboxd_hardcover_token}
          GB_API_KEY=${config.sops.placeholder.kinoboxd_gb_api_key}
          KINOBOXD_PASSWORD=${config.sops.placeholder.kinoboxd_password}
          STEAM_API_KEY=${config.sops.placeholder.kinoboxd_steam_api_key}
        '';
      };

      services.kinoboxd = {
        enable = true;
        profile = "/nix/var/nix/profiles/kinoboxd";
        port = 3229;
        stateDir = "/var/lib/kinoboxd";
        environmentFile = config.sops.templates."kinoboxd.env".path;
        booksBackfillLimit = 200;
        booksBackfillLitresBudget = 200;
        booksBackfillTimer.enable = true;
        booksBackfillTimer.interval = "hourly";
        booksResolveLimit = 200;
        booksResolveLitresBudget = 200;
        booksResolveGbBudget = 300;
        booksResolveRecheckDays = 90;
        booksResolveTimer.enable = true;
        booksResolveTimer.interval = "hourly";
      };
    };
}

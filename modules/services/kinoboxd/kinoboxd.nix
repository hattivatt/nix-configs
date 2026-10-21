# kinoboxd — site config / usage example (dendritic flake-parts style).
#
# This file only *configures* the service. The `services.kinoboxd` options
# themselves live in `module.nix`; both files define the same
# `flake.modules.nixos.kinoboxd` attribute, which flake-parts/import-tree
# merges. Enable the module on a host by adding `kinoboxd` to its imports:
#
#   imports = with inputs.self.modules.nixos; [ ... kinoboxd ];
#
# Secrets are managed with sops-nix, like koinsight/cwa. Add the two keys to
# `secrets/server.yaml` first:
#
#   sops secrets/server.yaml
#   # then add:
#   #   kinoboxd_tmdb_token: <TMDB v4 read access token>
#   #   kinoboxd_password: <password for the web UI/API>
#
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
      # systemd reads EnvironmentFile as root before dropping privileges, so the
      # rendered file does not need to be readable by the kinoboxd user.
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
        port = 3229;
        stateDir = "/var/lib/kinoboxd";
        environmentFile = config.sops.templates."kinoboxd.env".path;
        # package defaults to pkgs.local.kinoboxd (packages/kinoboxd/package.nix
        # through the pkgs-by-name overlay). Without the overlay, use:
        #   package = pkgs.callPackage ../../../packages/kinoboxd/package.nix { };

        # Book metadata backfill (`sudo systemctl start kinoboxd-backfill-books`).
        # One run touches at most 200 works and asks Литрес for at most 40 of
        # them, 2 s apart; the rest is Hardcover / Open Library, which are cheap.
        # Every run is idempotent: works that already have a first-publication
        # year are skipped, and a "nobody knows" verdict is cached for 30 days.
        booksBackfillLimit = 200;
        booksBackfillLitresBudget = 200;
        booksBackfillTimer.enable = true;
        booksBackfillTimer.interval = "hourly";

        # Scheduled metadata resolve for the unlinked tail of LiveLib profiles
        # (`sudo systemctl start kinoboxd-resolve-books`). A profile imported
        # once used to keep its unlinked works forever; this unit walks one
        # slice per run (Cyrillic → Литрес-first, ISBN → batched Hardcover,
        # the rest GB → OL, LiveLib card disabled). A "nothing found" verdict
        # is remembered for 90 days, so an hourly tick is cheap and does not
        # re-ask the same books; a budget/breaker/network skip stays a
        # candidate. The same `cache-book/resolve.lock` serialises it with an
        # import resolve pass, and `Conflicts=` keeps it away from the year
        # backfill (both spend the Литрес budget).
        booksResolveLimit = 200;
        booksResolveLitresBudget = 200;
        booksResolveGbBudget = 300;
        booksResolveRecheckDays = 90;
        booksResolveTimer.enable = true;
        booksResolveTimer.interval = "hourly";
      };
    };
}

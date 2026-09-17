{
  flake.modules.homeManager.syncthing =
  { config, ... }:
  {
    services.syncthing = {
      settings = {
        devices = {
          "thevalley" = {
            id = "KHGQWZQ-RBICUDG-5WZCFLC-2WOO5UY-BJ2GZHR-AJBVAYX-LNN4BYS-GXKHCQ7";
          };
        };
      };
    };
  };
}

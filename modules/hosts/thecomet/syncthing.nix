{
  flake.modules.homeManager.syncthing =
  { config, ... }:
  {
    services.syncthing = {
      settings = {
        devices = {
          "thecomet" = {
            id = "5ML67E2-U7KZMBU-EP6FG3C-4ETTASO-IJB6LQR-BF7JPMS-TOMRUPU-PLZ65QX";
          };
        };
      };
    };
  };
}

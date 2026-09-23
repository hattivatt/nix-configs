{
  flake.modules.nixos.preservation =
  { config, lib, ... }:
  {
    preservation = {
      enable = true;
      preserveAt."/persist" = {
        directories = [
          "/var/lib/systemd"
          "/var/log"
          {
            directory = "/var/lib/nixos";
            inInitrd = true;
          }
        ] ++ config.my.persist.directories;
        files = config.my.persist.files;
        users.hattivatt = {
          directories = [
            ".nixos"
            {
              directory = ".ssh";
              mode = "0700";
            }
          ] ++ lib.optionals (config.home-manager ? users.hattivatt)
        config.home-manager.users.hattivatt.my.persist.directories;
          files = lib.optionals (config.home-manager ? users.hattivatt)
        config.home-manager.users.hattivatt.my.persist.files;
        };
      };
    };
  };
}

{
  flake.modules.nixos.preservation =
  {
    preservation = {
      enable = true;
      preserveAt."/persist" = {
        directories = [
          "/var/lib/systemd"
          "/var/log"
          "/etc/ssh"
          {
            directory = "/var/lib/nixos";
            inInitrd = true;
          }
        ];
        files = [
          {
            file = "/etc/machine-id";
            inInitrd = true;
            how = "symlink";
            configureParent = true;
          }
        ];
        users.hattivatt = {
          directories = [
            "Downloads"
            "Documents"
            "Pictures"
            "Projects"
            ".local/state"
            ".local/share"
            ".nixos"
            ".config/Exodus"
            ".config/kdeconnect"
            ".config/Spotify"
            {
              directory = ".ssh";
              mode = "0700";
            }
            ".steam"
          ];
        };
      };
    };
  };
}

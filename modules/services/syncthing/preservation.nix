{
  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist".users.hattivatt.directories = [
      {
        directory = ".local/state/syncthing";
        mode = "0700";
      }
    ];
  };
}

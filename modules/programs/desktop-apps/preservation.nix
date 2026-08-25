{
  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist".users.hattivatt.directories = [
      {
        directory = ".local/state/wireplumber";
        mode = "0700";
      }
    ];
  };
}

{
  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist".users.hattivatt.directories = [
      {
        directory = ".local/share/mime";
        mode = "0700";
      }
    ];
  };
}

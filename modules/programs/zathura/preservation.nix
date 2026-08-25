{
  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist".users.hattivatt.directories = [
      {
        directory = ".local/share/zathura";
        mode = "0700";
      }
    ];
  };
}

{
  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist".users.hattivatt.directories = [
      {
        directory = ".local/state/nvim";
        mode = "0700";
      }
    ];
  };
}

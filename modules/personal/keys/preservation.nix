{
  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist".users.hattivatt.directories = [
      ".config/sops"
      {
        directory = ".local/share/gnupg";
        mode = "0700";
      }
      {
        directory = ".local/share/pki";
        mode = "0700";
      }
    ];
  };
}

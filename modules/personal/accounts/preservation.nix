{
  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist".users.hattivatt.directories = [
      ".local/share/calendars"
      ".local/share/contacts"
      ".local/share/pimsync"
      {
        directory = ".local/state/aerc";
        mode = "0700";
      }
    ];
  };
}

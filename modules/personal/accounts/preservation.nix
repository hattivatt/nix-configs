{
  flake.modules.homeManager.accounts = {
    my.persist.directories = [
      ".local/share/calendars"
      ".local/share/contacts"
      ".local/share/mails"
      ".local/share/pimsync"
    ];
  };
}

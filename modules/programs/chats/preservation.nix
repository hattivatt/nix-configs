{
  flake.modules.homeManager.chats = {
    my.persist.directories = [
      ".config/Mattermost"
      ".config/Slack"
      ".config/vesktop"
      {
        directory = ".local/share/TelegramDesktop";
        mode = "0700";
      }
    ];
  };
}

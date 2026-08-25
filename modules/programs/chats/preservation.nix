{
  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist".users.hattivatt.directories = [
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

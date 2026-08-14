{
  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist".users.hattivatt.directories = [
      ".config/Mattermost"
      ".config/Slack"
      ".config/vesktop"
    ];
  };
}

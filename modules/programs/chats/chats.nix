{
  flake.modules.homeManager.chats =
  { inputs, pkgs, ... }:
  {
    home.packages = with pkgs; [
      telegram-desktop
      slack
      mattermost-desktop
    ];
    xdg.dataFile."TelegramDesktop/tdata/shortcuts-custom.json".text = ''
      [
          {
              "command": "next_chat",
              "keys": "ctrl+j"
          },
          {
              "command": "previous_chat",
              "keys": "ctrl+k"
          },
          {
              "command": "next_folder",
              "keys": "ctrl+shift+j"
          },
          {
              "command": "previous_folder",
              "keys": "ctrl+shift+k"
          }
      ]
    '';
    imports = [
      inputs.self.modules.homeManager.vesktop
    ];
  };
}

{
  flake.modules.homeManager.chats =
  { inputs, pkgs, ... }:
  {
    home.packages = with pkgs; [
      telegram-desktop
      slack
      mattermost-desktop
    ];
    imports = [
      inputs.self.modules.homeManager.vesktop
    ];
  };
}

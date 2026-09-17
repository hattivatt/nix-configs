{
  flake.modules.homeManager.syncthing =
  { config, ... }:
  {
    sops = {
      secrets.syncthing_gui = { };
    };
    services.syncthing = {
      enable = true;
      overrideDevices = false;
      guiCredentials = {
        username = "hattivatt";
        passwordFile = "${config.sops.secrets.syncthing_gui.path}";
      };
      settings = {
        devices = {
          "Pixel 9" = {
            id = "XJLZHCK-SDSGKC3-MLCH6EU-JBUZICN-X4GDWGP-KDVCFCD-VH7EV2Z-OJ4DXQT";
          };
        };
        folders = {
          "${config.home.homeDirectory}/Notes" = {
            id = "b76m5-llmfh";
            label = "Notes";
            versioning.type = "simple";
            devices = [
              "thevalley"
              "Pixel 9"
            ];
            ignorePatterns = [
              ".obsidian"
            ];
          };
          "${config.xdg.dataHome}/FoundryVTT/common" = {
            label = "Foundry";
            versioning.type = "simple";
            devices = [
              "thevalley"
            ];
          };
        };
      };
    };
  };
}

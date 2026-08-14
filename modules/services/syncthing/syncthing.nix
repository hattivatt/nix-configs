{
  flake.modules.homeManager.syncthing =
  { config, ... }:
  {
    sops = {
      secrets.syncthing_cert = { };
      secrets.syncthing_key = { };
    };
    services.syncthing = {
      enable = true;
      cert = "${config.sops.secrets.syncthing_cert.path}";
      key = "${config.sops.secrets.syncthing_key.path}";
      overrideDevices = false;
      settings = {
        devices = {
          hatinote = {
            id = "KHGQWZQ-RBICUDG-5WZCFLC-2WOO5UY-BJ2GZHR-AJBVAYX-LNN4BYS-GXKHCQ7";
          };
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
              "hatinote"
              "Pixel 9"
            ];
          };
        };
      };
    };
  };
}

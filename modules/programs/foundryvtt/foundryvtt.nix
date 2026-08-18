{
  flake.modules.homeManager.foundryvtt =
  { config, ... }:
  {
    sops.secrets."foundry_secrets" = { };
    xdg.dataFile."FoundryVTT/docker/v13/secret.json".source = config.lib.file.mkOutOfStoreSymlink config.sops.secrets."foundry_secrets".path;
    xdg.dataFile."FoundryVTT/docker/v13/compose.yml".text = ''
      ---
      secrets:
        config_json:
          file: secrets.json
      services:
        foundry:
          image: ghcr.io/felddy/foundryvtt:13
          hostname: myf
          volumes:
            - type: bind
              source: /home/hattivatt/.local/share/FoundryVTT/common
              target: /common
            - type: bind
              source: /home/hattivatt/.local/share/FoundryVTT/v13
              target: /data
          environment:
            - FOUNDRY_TELEMETRY=true
          ports:
            - target: 30000
              published: 30000
              protocol: tcp
          secrets:
            - source: config_json
              target: config.json
    '';
    xdg.dataFile."FoundryVTT/docker/v14/secret.json".source = config.lib.file.mkOutOfStoreSymlink config.sops.secrets."foundry_secrets".path;
    xdg.dataFile."FoundryVTT/docker/v14/compose.yml".text = ''
      ---
      secrets:
        config_json:
          file: secrets.json
      services:
        foundry:
          image: ghcr.io/felddy/foundryvtt:14
          hostname: myf
          volumes:
            - type: bind
              source: /home/hattivatt/.local/share/FoundryVTT/common
              target: /common
            - type: bind
              source: /home/hattivatt/.local/share/FoundryVTT/v14
              target: /data
          environment:
            - FOUNDRY_TELEMETRY=true
          ports:
            - target: 30000
              published: 30000
              protocol: tcp
          secrets:
            - source: config_json
              target: config.json
    '';
  };
}

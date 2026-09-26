{ inputs, ... }:
{
  flake.modules.nixos.system-server = {
    imports = with inputs.self.modules.nixos; [
      system-cli
      nix-gc
      agents
      rebuild
      docker
      caddy
      sops
      server-apps
      mtproxy
    ];
  };
  flake.modules.homeManager.system-server = {
    imports = with inputs.self.modules.homeManager; [
      system-cli
      agents
      pass
      theme
      syncthing
      foundryvtt
      serverkeys
      server-apps
    ];
  };
}


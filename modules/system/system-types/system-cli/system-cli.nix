{ inputs, ... }:
{
  flake.modules.nixos.system-cli = {
    imports = with inputs.self.modules.nixos; [
      system-default
      shells
    ];
  };
  flake.modules.homeManager.system-cli = {
    imports = with inputs.self.modules.homeManager; [
      system-default
      sops
      shells
      herdr
      nixvim
      vcs
      yazi
    ];
  };
}


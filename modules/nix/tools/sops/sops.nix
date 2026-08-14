{
  flake.modules.homeManager.sops =
  { inputs, pkgs, config, ... }:
  {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
    ];
    home.packages = with pkgs; [
      age
      sops
    ];
    sops = {
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      defaultSopsFile = inputs.secrets;
      defaultSopsFormat = "yaml";
    };
  };
}

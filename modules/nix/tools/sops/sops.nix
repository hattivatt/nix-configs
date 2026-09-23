{
  flake.modules.homeManager.sops =
  { inputs, pkgs, config, lib, ... }:
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
      defaultSopsFile = lib.mkDefault "${inputs.secrets}/secrets.yaml";
      defaultSopsFormat = "yaml";
    };
  };
  flake.modules.nixos.sops =
  { inputs, pkgs, config, lib, ... }:
  {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];
    environment.systemPackages = with pkgs; [
      age
      sops
    ];
    sops = {
      age.keyFile = "/home/hattivatt/.config/sops/age/keys.txt";
      defaultSopsFile = lib.mkDefault "${inputs.secrets}/secrets.yaml";
      defaultSopsFormat = "yaml";
    };
  };
}

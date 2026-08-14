{
  flake.modules.homeManager.system-minimal =
    { config, pkgs, lib, ... }:
    {
      home.homeDirectory = "/home/${config.home.username}";
      home.stateVersion = "26.05";
      home.pointerCursor.enable = true;
      xdg.enable = true;
      nix = {
        package = lib.mkDefault pkgs.nix;
        settings = {
          experimental-features = [ "nix-command" "flakes" ];
          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };
      };
    };
}


{ inputs, ... }:
{
  flake.modules.nixos.obsidian-plugins = {
    nixpkgs.overlays = [ inputs.obsidian-plugins.overlays.default ];
  };
}

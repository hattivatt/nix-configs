{ inputs, ... }:
{
  flake-file.inputs = {
    obsidian-plugins = {
      url = "github:cjavad/nixpille-obsidian-community-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}

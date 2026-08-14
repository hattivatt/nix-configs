{
  flake.modules.homeManager.nixvim =
  { inputs, ... }:
  {
    imports = [ inputs.nixvim.homeModules.nixvim ];
    programs.nixvim.enable = true;
    programs.nixvim.imports = [ ./_parts/plugins.nix ./_parts/options.nix ./_parts/lsps.nix ./_parts/keys.nix ];

  };
}

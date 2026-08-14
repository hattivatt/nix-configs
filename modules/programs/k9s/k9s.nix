{
  flake.modules.homeManager.k9s =
  {
    programs.k9s = {
      enable = true;
    };
    imports = [
      ./_parts/settings.nix
      ./_parts/aliases.nix
      ./_parts/plugins-flux.nix
    ];
  };
}

{
  flake.modules.homeManager.xkb =
  {
    xdg.configFile."xkb/symbols" = {
      source = ./layouts;
      recursive = true;
    };
  };
}

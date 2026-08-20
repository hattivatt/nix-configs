{
  flake.modules.homeManager.foot =
  {
    programs.foot = {
      enable = true;
      settings = {
        main = {
          term = "xterm-256color";
          font = "FiraCodeNerdFontMono:size=11";
        };
        colors-dark.alpha = 0.9;
        colors-light.alpha = 0.9;
      };
    };
  };
}

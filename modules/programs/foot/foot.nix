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
        colors.alpha = 0.9;
      };
    };
  };
}

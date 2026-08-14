{
  flake.modules.homeManager.fuzzel =
  {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          icon-theme = "Papirus";
          launch-prefix = "uwsm app -- ";
          lines = 20;
          width = 50;
          image-size-ratio = 0.5;
        };
        colors = {
          background = "1e1e2edd";
          text = "cdd6f4ff";
          prompt = "bac2deff";
          placeholder = "7f849cff";
          input = "cdd6f4ff";
          match = "f38ba8ff";
          selection = "585b70ff";
          selection-text = "cdd6f4ff";
          selection-match = "f38ba8ff";
          counter = "7f849cff";
          border = "f38ba8ff";
        };
      };
    };
  };
}

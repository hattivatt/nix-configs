{
  flake.modules.homeManager.zathura =
  { inputs, pkgs, ... }:
  {
    programs.zathura = {
      enable = true;
      options = {
        selection-clipboard = "clipboard";
        default-fg = "rgba(205,214,244,1)";
        default-bg = "rgba(30,30,46,1)";
        completion-bg = "rgba(49,50,68,1)";
        completion-fg = "rgba(205,214,244,1)";
        completion-highlight-bg = "rgba(203,166,247,1)";
        completion-highlight-fg = "rgba(30,30,46,1)";
        completion-group-bg = "rgba(24,24,37,1)";
        completion-group-fg = "rgba(205,214,244,1)";
        statusbar-fg = "rgba(205,214,244,1)";
        statusbar-bg = "rgba(17,17,27,1)";
        inputbar-fg = "rgba(205,214,244,1)";
        inputbar-bg = "rgba(30,30,46,1)";
        notification-bg = "ba(30,30,46,1)";
        notification-fg = "ba(205,214,244,1)";
        notification-error-bg = "ba(30,30,46,1)";
        notification-error-fg = "ba(243,139,168,1)";
        notification-warning-bg = "ba(30,30,46,1)";
        notification-warning-fg = "ba(249,226,175,1)";
        recolor = "true";
        recolor-keephue = "true";
        recolor-lightcolor = "ba(30,30,46,1)";
        recolor-darkcolor = "ba(205,214,244,1)";
        index-fg = "ba(205,214,244,1)";
        index-bg = "ba(30,30,46,1)";
        index-active-fg = "ba(205,214,244,1)";
        index-active-bg = "ba(49,50,68,1)";
        render-loading-bg = "ba(30,30,46,1)";
        render-loading-fg = "ba(205,214,244,1)";
        highlight-color = "ba(147,153,178,0.3)";
        highlight-fg = "ba(205,214,244,1)";
        highlight-active-color = "ba(203,166,247,0.3)";
      };
    };
    catppuccin.zathura.enable = false;
  };
}

{
  flake.modules.homeManager.herdr =
    { config, ... }:
    {
      programs.herdr = {
        enable = true;
        settings = {
          onboarding = false;
          terminal.default_shell = "nu";
          worktrees.directory = "${config.xdg.dataHome}/herdr";
          keys = {
            prefix = "ctrl+s";
          };
          ui = {
            show_agent_labels_on_pane_borders = true;
            hide_tab_bar_when_single_tab = true;
            toast.delivery = "system";
            sound.enabled = false;
          };
        };
      };
    };
}

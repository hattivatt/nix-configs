{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jj-starship
  ];
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      format = "$all";
      package.disabled = true;
      aws.disabled = true;
      gcloud.disabled = true;
      python.disabled = true;
      kubernetes.disabled = false;
      git_status.disabled = true;
      git_branch.disabled = true;
      git_commit.disabled = true;
      custom.jj = {
        when = "jj-starship detect";
        shell = ["jj-starship"];
        format = "$output";
      };
    };
  };
}

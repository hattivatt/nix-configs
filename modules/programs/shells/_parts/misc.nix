{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      if ! [ "$TERM" = "dumb" ] && [ -z "$BASH_EXECUTION_STRING" ]; then
        exec nu
      fi
    '';
  };
  home.shellAliases = {
    vim = "nvim";
    vimd = "nvim -d";
    wget = "wget --hsts-file='$XDG_DATA_HOME/wget-hsts'";
    vs = "vaultsearch";
    tf = "terraform";
    tg = "terragrunt";
    gnb = "git checkout -b";
    gpl = "git pull";
    gcm = "git commit -a";
    gadd = "git add .";
    gph = "git push";
    syncmovies = "rclone sync /home/hattivatt/Downloads/MoviesAndShows /run/media/hattivatt/UD12/Movies -P --transfers 8 --checkers 16";
    jgi = "jj git init --colocate";
    jd = "jj describe";
    jgf = "jj git fetch";
    jgp = "jj git push";
    obn = "nvim ~/Notes/ObsidianNotes/QuickNote.md";
    ll = "ls -la";
  };
  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
  };
}

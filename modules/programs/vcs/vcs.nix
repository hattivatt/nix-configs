{
  flake.modules.homeManager.vcs =
  { pkgs, config, ... }:
  {
    programs.git = {
      enable = true;
      lfs.enable = true;
      settings = {
        user = {
          email = "hattivatt@disroot.org";
          name = "Vladimir Vasilenko";
        };
        push.autoSetupRemote = true;
        protocol."file".allow = "always";
        filter."lfs" = {
          required = true;
        };
        credential = {
          helper = [
            "cache"
            "gopass"
          ];
        };
      };
    };
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          email = "hattivatt@disroot.org";
          name = "Vladimir Vasilenko";
        };
      };
    };
    programs.difftastic = {
      enable = true;
      jujutsu.enable = true;
      options.display = "side-by-side-show-both";
    };
    programs.gh = {
      enable = true;
    };
  };
}

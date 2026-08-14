{
  flake.modules.homeManager.vcs =
  { pkgs, ... }:
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
            "!pass-git-helper $@"
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
    home.packages = with pkgs; [
      pass-git-helper
    ];
  };
}

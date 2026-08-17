{
  flake.modules.homeManager.yazi =
    { pkgs, ... }:
    {
      catppuccin.yazi.accent = "maroon";
      programs.yazi = {
        enable = true;
        enableNushellIntegration = false;
        enableZshIntegration = true;
        initLua = ./_parts/init.lua;
        plugins = {
          chmod = pkgs.yaziPlugins.chmod;
          mediainfo = pkgs.yaziPlugins.mediainfo;
          starship = pkgs.yaziPlugins.starship;
          ouch = pkgs.yaziPlugins.ouch;
          bookmarks = pkgs.yaziPlugins.bookmarks;
          kdeconnect-send = pkgs.yaziPlugins.kdeconnect-send;
          yafg = {
            package = pkgs.yaziPlugins.yafg;
            settings.editor = "nvim";
          };
        };
      };
      imports = [
        ./_parts/yazi.nix
        ./_parts/keymap.nix
      ];
  };
}

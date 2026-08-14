{
  flake.modules.homeManager.mpv =
    { osConfig ? null, lib, pkgs, ... }:
    let
      scriptsDir = pkgs.symlinkJoin {
        name = "mpv-scripts";
        paths = [
          pkgs.mpvScripts.autoload
          pkgs.mpvScripts.mpris
          pkgs.local.mpv-channel-mixer
          pkgs.local.mpv-open-kinopoisk-page
          pkgs.local.mpv-file-browser
        ];
      };
    in
    {
      catppuccin.mpv.enable = false;
      programs.mpv = lib.mkMerge [
        {
          enable = true;
          config = {
            ao = "${toString "pulse"}";
            profile = "gpu-hq,builtin-pseudo-gui";
            hwdec = "no";
            slang = "rus";
            alang = "eng";
            log-file = "/tmp/mpv.log";
            af= ''pan="stereo|FL=0.707*FC+0.3*FL+0.1*BL+0.1*LFE|FR=0.707*FC+0.3*FR+0.1*BR+0.1*LFE"'';
            audio-file-auto = "exact";
            target-colorspace-hint = "no";
          };
          extraInput = ''
            ctrl+p script-message osc-playlist
            ALT+k add sub-scale +0.1
            ALT+j add sub-scale -0.1
            UP add volume +5
            DOWN add volume -5
            LEFT seek -2
            RIGHT seek 2
            B script_binding myshows_mark
            g ignore
          '';
        }
        (lib.mkIf (osConfig != null) {
          package = pkgs.mpv;
        })
        (lib.mkIf (osConfig == null) {
          package = pkgs.emptyDirectory;
        })
      ];
      xdg.configFile."mpv/script-opts" = {
        source = ./script-opts;
        recursive = true;
      };
      xdg.configFile."mpv/scripts" = {
        source = "${scriptsDir}/share/mpv/scripts";
        recursive = true;
      };
    };
}

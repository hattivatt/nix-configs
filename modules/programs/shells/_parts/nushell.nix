{
  programs.nushell = {
    enable = true;
    environmentVariables = {
      EDITOR = "nvim";
      SYSTEMD_EDITOR = "nvim";
      DIFFPROG = "nvim -d";
      VISUAL = "nvim";
      TERMINAL = "foot";
      BROWSER = "zen-browser";
      VIDEO = "mpv";
      IMAGE = "imv";
      COLORTERM = "truecolor";
      OPENER = "xdg-open";
      PAGER = "less";
      WM = "hyprland";
    };
    settings = {
      show_banner = false;
      edit_mode = "vi";
    };
    extraConfig = ''
      # fastfetch
      $env.PATH ++= ["~/.config/scripts","~/.local/bin"]
      def create_left_prompt [] {
          starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
      }
      # Use nushell functions to define your right and left prompt
      $env.PROMPT_COMMAND = { || create_left_prompt }
      $env.PROMPT_COMMAND_RIGHT = ""

      # The prompt indicators are environmental variables that represent
      # the state of the prompt
      $env.PROMPT_INDICATOR = ""
      $env.PROMPT_INDICATOR_VI_INSERT = ": "
      $env.PROMPT_INDICATOR_VI_NORMAL = "〉"
      $env.PROMPT_MULTILINE_INDICATOR = "::: "

      # Functions
      def ksc [] {
          kubectl config use-context (kubectl config get-contexts --output='name' | fzf)
      }
      def ced [] {
          let f = (chezmoi list | fzf)
          chezmoi edit -a $"~/($f)"
      }
      def --env y [...args] {
        let tmp = (mktemp -t "yazi-cwd.XXXXX")
        ^yazi ...$args --cwd-file $tmp

        # Если исходная директория была удалена, пока работал yazi, $env.PWD
        # указывает на несуществующий путь. cd в заведомо существующую директорию
        # чинит PWD; других команд, работающих при битом PWD, нет.
        cd $env.HOME

        let cwd = (open $tmp)
        if $cwd != "" and $cwd != $env.PWD {
          cd $cwd
        }
        rm -fp $tmp
      }
      $env.config = {
          keybindings: [
              {
                  name: yazi_cd
                  modifier: control
                  keycode: char_y
                  mode: [emacs, vi_normal, vi_insert]
                  event: {
                      send: executehostcommand
                      cmd: "y"
                  }
              }
              {
                  name: herdr-work
                  modifier: control_alt
                  keycode: char_h
                  mode: [emacs, vi_normal, vi_insert]
                  event: {
                      send: executehostcommand
                      cmd: "herdr --session zvuk"
                  }
              }
              {
                  name: herdr
                  modifier: control
                  keycode: char_h
                  mode: [emacs, vi_normal, vi_insert]
                  event: {
                      send: executehostcommand
                      cmd: "herdr"
                  }
              }
          ]
      }
    '';
  };
}

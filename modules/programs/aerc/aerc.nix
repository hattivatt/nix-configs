{
  flake.modules.homeManager.aerc =
  { config, ... }:
  {
    programs.aerc = {
      enable = true;
      extraAccounts = {
        mail = {
          from = "Ty <ty@gmail.com>";
          source = "notmuch://";
          outgoing = "sendmail";
          enable-maildir = false;
          query-map = "${config.xdg.configHome}/aerc/query-map";
          check-mail = "5m";
          check-mail-cmd = "notmuch new";
          check-mail-timeout = "120s";
        };
      };
      extraConfig = {
        general.unsafe-accounts-conf = true;
        hooks.mail-received = ''notify-send "New mail from $AERC_FROM_NAME" "$AERC_SUBJECT"'';
        filters = {
          "text/plain" = "colorize";
          "text/html" = "! html-unsafe -sixel";
        };
        viewer.show-images = true;
        viewer.html-inline-images = true;
        viewer.alternatives = "text/html,text/plain";
      };
      extraBinds = {
        global = {
          "<C-p>" = ":prev-tab<Enter>";
          "<C-PgUp>" = ":prev-tab<Enter>";
          "<C-n>" = ":next-tab<Enter>";
          "<C-PgDn>" = ":next-tab<Enter>";
          "\\[t" = ":prev-tab<Enter>";
          "\\]t" = ":next-tab<Enter>";
          "<C-t>" = ":term<Enter>";
          "?" = ":help keys<Enter>";
          "<C-c>" = ":prompt 'Quit?' quit<Enter>";
          "<C-q>" = ":prompt 'Quit?' quit<Enter>";
          "<C-z>" = ":suspend<Enter>";
        };
        messages = {
          q = ":prompt 'Quit?' quit<Enter>";
          "." = ":repeat";
          j = ":next<Enter>";
          "<Down>" = ":next<Enter>";
          "<C-d>" = ":next 50%<Enter>";
          "<C-f>" = ":next 100%<Enter>";
          "<PgDn>" = ":next 100%<Enter>";
          k = ":prev<Enter>";
          "<Up>" = ":prev<Enter>";
          "<C-u>" = ":prev 50%<Enter>";
          "<C-b>" = ":prev 100%<Enter>";
          "<PgUp>" = ":prev 100%<Enter>";
          g = ":select 0<Enter>";
          G = ":select -1<Enter>";
          J = ":next-folder<Enter>";
          "<C-Down>" = ":next-folder<Enter>";
          K = ":prev-folder<Enter>";
          "<C-Up>" = ":prev-folder<Enter>";
          H = ":collapse-folder<Enter>";
          "<C-Left>" = ":collapse-folder<Enter>";
          L = ":expand-folder<Enter>";
          "<C-Right>" = ":expand-folder<Enter>";
          tf = ":toggle-folder<Enter>";
          v = ":mark -t<Enter>";
          "<Space>" = ":mark -t<Enter>:next<Enter>";
          V = ":mark -v<Enter>";
          T = ":toggle-threads<Enter>";
          zc = ":fold<Enter>";
          zo = ":unfold<Enter>";
          za = ":fold -t<Enter>";
          zM = ":fold -a<Enter>";
          zR = ":unfold -a<Enter>";
          "<tab>" = ":fold -t<Enter>";
          zz = ":align center<Enter>";
          zt = ":align top<Enter>";
          zb = ":align bottom<Enter>";
          "<Enter>" = ":view<Enter>";
          d = ":modify-labels +trash -inbox -keep -unread<Enter>";
          D = ":modify-labels +trash -inbox -keep -unread<Enter>";
          a = ":archive flat<Enter>";
          A = ":unmark -a<Enter>:mark -T<Enter>:archive flat<Enter>";
          C = ":compose<Enter>";
          m = ":compose<Enter>";
          b = ":bounce<space>";
          rr = ":reply -a<Enter>";
          rq = ":reply -aq<Enter>";
          Rr = ":reply<Enter>";
          Rq = ":reply -q<Enter>";
          c = ":cf<space>";
          "$" = ":term<space>";
          "!" = ":term<space>";
          "|" = ":pipe<space>";
          "/" = ":search<space>";
          "\\" = ":filter<space>";
          n = ":next-result<Enter>";
          N = ":prev-result<Enter>";
          "<Esc>" = ":clear<Enter>";
          s = ":split<Enter>";
          S = ":vsplit<Enter>";
          pl = ":patch list<Enter>";
          pa = ":patch apply <Tab>";
          pd = ":patch drop <Tab>";
          pb = ":patch rebase<Enter>";
          pt = ":patch term<Enter>";
          ps = ":patch switch <Tab>";
        };
        "messages:folder=Drafts" = {
          "<Enter>" = ":recall<Enter>";
        };
        view = {
          "/" = ":toggle-key-passthrough<Enter>/";
          q = ":close<Enter>";
          O = ":open<Enter>";
          o = ":open<Enter>";
          S = ":save<space>";
          "|" = ":pipe<space>";
          D = ":modify-labels +trash -inbox -keep -unread<Enter>";
          A = ":archive flat<Enter>";
          "<C-y>" = ":copy-link <space>";
          "<C-l>" = ":open-link <space>";
          f = ":forward<Enter>";
          rr = ":reply -a<Enter>";
          rq = ":reply -aq<Enter>";
          Rr = ":reply<Enter>";
          Rq = ":reply -q<Enter>";
          H = ":toggle-headers<Enter>";
          "<C-k>" = ":prev-part<Enter>";
          "<C-Up>" = ":prev-part<Enter>";
          "<C-j>" = ":next-part<Enter>";
          "<C-Down>" = ":next-part<Enter>";
          J = ":next<Enter>";
          "<C-Right>" = ":next<Enter>";
          K = ":prev<Enter>";
          "<C-Left>" = ":prev<Enter>";
        };
        "view::passthrough" = {
          "$noinherit" = true;
          "$ex" = "<C-x>";
          "<Esc>" = ":toggle-key-passthrough<Enter>";
        };
        compose = {
          "$noinherit" = true;
          "$ex" = "<C-x>";
          "$complete" = "<C-o>";
          "<C-k>" = ":prev-field<Enter>";
          "<C-Up>" = ":prev-field<Enter>";
          "<C-j>" = ":next-field<Enter>";
          "<C-Down>" = ":next-field<Enter>";
          "<A-p>" = ":switch-account -p<Enter>";
          "<A-n>" = ":switch-account -n<Enter>";
          "<tab>" = ":next-field<Enter>";
          "<backtab>" = ":prev-field<Enter>";
          "<C-p>" = ":prev-tab<Enter>";
          "<C-PgUp>" = ":prev-tab<Enter>";
          "<C-n>" = ":next-tab<Enter>";
          "<C-PgDn>" = ":next-tab<Enter>";
        };
        "compose::editor" = {
          "$noinherit" = true;
          "$ex" = "<C-x>";
          "<C-k>" = ":prev-field<Enter>";
          "<C-Up>" = ":prev-field<Enter>";
          "<C-j>" = ":next-field<Enter>";
          "<C-Down>" = ":next-field<Enter>";
          "<C-p>" = ":prev-tab<Enter>";
          "<C-PgUp>" = ":prev-tab<Enter>";
          "<C-n>" = ":next-tab<Enter>";
          "<C-PgDn>" = ":next-tab<Enter>";
        };
        "compose::review" = {
          y = ":send<Enter>";
          n = ":abort<Enter>";
          s = ":sign<Enter>";
          x = ":encrypt<Enter>";
          v = ":preview<Enter>";
          p = ":postpone<Enter>";
          q = ":choose -o d discard abort -o p postpone postpone<Enter>";
          e = ":edit<Enter>";
          a = ":attach<space>";
          d = ":detach<space>";
        };
        terminal = {
          "$noinherit" = true;
          "$ex" = "<C-x>";
          "<C-p>" = ":prev-tab<Enter>";
          "<C-n>" = ":next-tab<Enter>";
          "<C-PgUp>" = ":prev-tab<Enter>";
          "<C-PgDn>" = ":next-tab<Enter>";
        };
      };
    };
    xdg.configFile."aerc/query-map".text = ''
      Inbox=tag:inbox and not tag:deleted
      Unread=tag:unread
      Keep=tag:keep
      Sent=tag:sent
      Lists=tag:lists and tag:unread
      gmail-ax=tag:gmail-ax and not tag:trash
      disroot=tag:disroot and not tag:trash
      gmail-ht=tag:gmail-ht and not tag:trash
      yandex=tag:yandex-ax and not tag:trash
      zvuk=tag:zvuk and not tag:trash
      forjob-gm=tag:forjob-gm and not tag:trash
      Trash=tag:trash
    '';
  };
}

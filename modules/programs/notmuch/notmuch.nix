{
  flake.modules.homeManager.notmuch =
  { pkgs, ... }:
  {
    home.packages = [
      pkgs.notmuch-mailmover
    ];
    programs.notmuch = {
      enable = true;
      settings = {
        new.tags = [ "unread" "inbox" "new" ];
        search.excludeTags = [ "spam" ];
        maildir.synchronizeFlags = true;
      };
      hooks = {
        preNew = ''
          notmuch-mailmover
          mbsync -a
        '';
        postNew = "afew --tag --new -C ~/.config/notmuch/default/config && { mailnotif; notmuch tag -new -- tag:new; }";
      };
    };
    xdg.configFile."notmuch-mailmover/config.yaml".text = ''
      maildir: ~/.local/share/mails
      notmuch_config: ~/.config/notmuch/default/config
      rename: true
      rules:
        # trash: INBOX -> Trash
        - query: "tag:trash and tag:gmail-ax"
          folder: "axisinvictus-gm/[Gmail]/Trash"
          prefix: axisinvictus-gm
        - query: "tag:trash and tag:disroot"
          folder: "hattivatt-disroot/Trash"
          prefix: hattivatt-disroot
        - query: "tag:trash and tag:yandex-ax"
          folder: "axisinvictus-ya/Trash"
          prefix: axisinvictus-ya
        - query: "tag:trash and tag:gmail-ht"
          folder: "hattivattam-gm/[Gmail]/Trash"
          prefix: hattivattam-gm
        - query: "tag:trash and tag:zvuk"
          folder: "zvuk/Trash"
          prefix: zvuk
        - query: "tag:trash and tag:forjob-gm"
          folder: "forjob-gm/[Gmail]/Trash"
          prefix: forjob-gm

        # keep: INBOX -> Keep
        - query: "tag:keep and tag:gmail-ax and not tag:trash"
          folder: "axisinvictus-gm/Keep"
          prefix: axisinvictus-gm
        - query: "tag:keep and tag:disroot and not tag:trash"
          folder: "hattivatt-disroot/Keep"
          prefix: hattivatt-disroot
        - query: "tag:keep and tag:yandex-ax and not tag:trash"
          folder: "axisinvictus-ya/Keep"
          prefix: axisinvictus-ya
        - query: "tag:keep and tag:gmail-ht and not tag:trash"
          folder: "hattivattam-gm/Keep"
          prefix: hattivattam-gm
        - query: "tag:keep and tag:zvuk and not tag:trash"
          folder: "zvuk/Keep"
          prefix: zvuk
        - query: "tag:keep and tag:forjob-gm and not tag:trash"
          folder: "forjob-gm/Keep"
          prefix: forjob-gm

        # keep: обратно
        - query: >-
            not tag:keep and not tag:trash and
            (path:axisinvictus-gm/Keep/**
            or path:axisinvictus-gm/[Gmail]/Trash/**)
          folder: "axisinvictus-gm/INBOX"
          prefix: axisinvictus-gm
        - query: >-
            not tag:keep and not tag:trash and
            (path:hattivatt-disroot/Keep/**
            or path:hattivatt-disroot/Trash/**)
          folder: "hattivatt-disroot/INBOX"
          prefix: hattivatt-disroot
        - query: >-
            not tag:keep and not tag:trash and
            (path:axisinvictus-ya/Keep/**
            or path:axisinvictus-ya/Trash/**)
          folder: "axisinvictus-ya/INBOX"
          prefix: axisinvictus-ya
        - query: >-
            not tag:keep and not tag:trash and
            (path:hattivattam-gm/Keep/**
            or path:hattivattam-gm/[Gmail]/Trash/**)
          folder: "hattivattam-gm/INBOX"
          prefix: hattivattam-gm
        - query: >-
            not tag:keep and not tag:trash and
            (path:zvuk/Keep/**
            or path:zvuk/Trash/**)
          folder: "zvuk/INBOX"
          prefix: zvuk
        - query: >-
            not tag:keep and not tag:trash and
            (path:forjob-gm/Keep/**
            or path:forjob-gm/[Gmail]/Trash/**)
          folder: "forjob-gm/INBOX"
          prefix: forjob-gm
    '';
  };
}

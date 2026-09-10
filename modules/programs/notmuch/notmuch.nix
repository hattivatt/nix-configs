{
  flake.modules.homeManager.notmuch =
  { pkgs, ... }:
  {
    home.packages = [
      pkgs.notmuch-mailmover
    ];
    programs.notmuch = {
      enable = true;
      new.tags = [ "unread" "inbox" "new" ];
      search.excludeTags = [ "spam" ];
      maildir.synchronizeFlags = true;
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
        # keep: INBOX -> Keep
        - query: "tag:keep and tag:gmail-ax"
          folder: "axisinvictus-gm/Keep"
          prefix: axisinvictus-gm
        - query: "tag:keep and tag:disroot"
          folder: "hattivatt-disroot/Keep"
          prefix: hattivatt-disroot
        - query: "tag:keep and tag:yandex-ax"
          folder: "axisinvictus-ya/Keep"
          prefix: axisinvictus-ya
        - query: "tag:keep and tag:gmail-ht"
          folder: "hattivattam-gm/Keep"
          prefix: hattivattam-gm
        - query: "tag:keep and tag:zvuk"
          folder: "zvuk/Keep"
          prefix: zvuk
        - query: "tag:keep and tag:forjob-gm"
          folder: "forjob-gm/Keep"
          prefix: forjob-gm

        # keep: обратно
        - query: "not tag:keep and path:axisinvictus-gm/Keep/**"
          folder: "axisinvictus-gm/INBOX"
          prefix: axisinvictus-gm
        - query: "not tag:keep and path:hattivatt-disroot/Keep/**"
          folder: "hattivatt-disroot/INBOX"
          prefix: hattivatt-disroot
        - query: "not tag:keep and path:axisinvictus-ya/Keep/**"
          folder: "axisinvictus-ya/INBOX"
          prefix: axisinvictus-ya
        - query: "not tag:keep and path:hattivattam-gm/Keep/**"
          folder: "hattivattam-gm/INBOX"
          prefix: hattivattam-gm
        - query: "not tag:keep and path:zvuk/Keep/**"
          folder: "zvuk/INBOX"
          prefix: zvuk
        - query: "not tag:keep and tag:forjob-gm"
          folder: "forjob-gm/INBOX"
          prefix: forjob-gm

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

        # trash: обратно
        - query: "not tag:trash and path:axisinvictus-gm/[Gmail]/Trash/**"
          folder: "axisinvictus-gm/INBOX"
          prefix: axisinvictus-gm
        - query: "not tag:trash and path:hattivatt-disroot/Trash/**"
          folder: "hattivatt-disroot/INBOX"
          prefix: hattivatt-disroot
        - query: "not tag:trash and path:axisinvictus-ya/Trash/**"
          folder: "axisinvictus-ya/INBOX"
          prefix: axisinvictus-ya
        - query: "not tag:trash and path:hattivattam-gm/[Gmail]/Trash/**"
          folder: "hattivattam-gm/INBOX"
          prefix: hattivattam-gm
        - query: "not tag:trash and path:zvuk/Trash/**"
          folder: "zvuk/INBOX"
          prefix: zvuk
        - query: "not tag:trash and tag:forjob-gm"
          folder: "forjob-gm/INBOX"
          prefix: forjob-gm
    '';
  };
}

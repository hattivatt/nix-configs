{
  flake.modules.homeManager.afew = {
    programs.afew = {
      enable = true;
      extraConfig = ''
        [SpamFilter]
        [KillThreadsFilter]
        [ListMailsFilter]

        [FolderNameFilter]
        folder_explicit_list = Keep
        folder_lowercases = true
        maildir_separator = /

        [Filter.0]
        query = path:axisinvictus-gm/**
        tags = +gmail-ax

        [Filter.1]
        query = path:hattivatt-disroot/**
        tags = +disroot

        [Filter.2]
        query = path:axisinvictus-ya/**
        tags = +yandex-ax

        [Filter.3]
        query = path:hattivattam-gm/**
        tags = +gmail-ht

        [Filter.4]
        query = path:zvuk/**
        tags = +zvuk;+work

        [Filter.5]
        query = path:forjob-gm/**
        tags = +forjob

        [Filter.6]
        query = from:atlassian@zvuk.com to:ops@sber-zvuk.com
        tags = +jira;-inbox;-new

        [Filter.7]
        query = from:gitlab@zvuk.com to:ops-sc@zvuk.com
        tags = +trash;-inbox;-new

        [Filter.8]
        query = folder:"/^.*/Trash$/"
        tags = +trash;-inbox;-new
      '';
    };
  };
}

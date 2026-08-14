{
  flake.modules.homeManager.obsidian =
  {
    programs.obsidian = {
      enable = true;
      defaultSettings = {
        app = {
          promptDelete = false;
          alwaysUpdateLinks = true;
          vimMode = true;
          newFileLocation = "folder";
          showLineNumber = true;
          attachmentFolderPath = "./attachments";
          newFileFolderPath = "1Inbox";
        };
        hotkeys = {
          "editor:toggle-strikethrough" = [
            {
              modifiers = [ "Mod" ];
              key = "`";
            }
          ];
          "insert-template" = [
            {
              modifiers = [ "Mod" ];
              key = "A";
            }
          ];
        };
        corePlugins = [
          {
            name = "file-explorer";
          }
          {
            name = "global-search";
          }
          {
            name = "switcher";
          }
          {
            name = "graph";
          }
          {
            name = "backlink";
          }
          {
            name = "canvas";
          }
          {
            name = "outgoing-link";
          }
          {
            name = "tag-pane";
          }
          {
            name = "page-preview";
          }
          {
            name = "templates";
            settings = {
              folder = "Templates";
            };
          }
          {
            name = "note-composer";
          }
          {
            name = "command-palette";
          }
          {
            name = "editor-status";
          }
          {
            name = "bookmarks";
          }
          {
            name = "outline";
          }
          {
            name = "word-count";
          }
          {
            name = "file-recovery";
          }
          {
            name = "bases";
          }
        ];
      };
    };
    imports = [
      ./_vaults/notes.nix
    ];
  };
}

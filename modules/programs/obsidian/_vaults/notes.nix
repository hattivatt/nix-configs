{ pkgs, ... }:
let
  Catppuccin = pkgs.stdenvNoCC.mkDerivation {
    pname = "Catppuccin";
    version = "0.4.47";

    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo  = "obsidian";
      rev   = "55aa9c9";    # commit или tag
      hash  = "sha256-uB0a2nSZkHHf65xBYXyNh50vaAiqdEpKQVf3eXnCVlE=";
    };

    installPhase = ''
      mkdir -p $out
      cp theme.css manifest.json $out/
    '';
  };
in
{
  programs.obsidian.vaults.ObsidianNotes = {
    target = "Notes/ObsidianNotes";
    settings = {
      appearance = {
        "theme" = "obsidian";
        "cssTheme" = "Catppuccin";
        "accentColor" = "#5f3641";
      };
      themes = [
        {
          pkg = Catppuccin;
        }
      ];
      communityPlugins = [
        {
          pkg = pkgs.obsidianPlugins.task-list-kanban;
        }
        {
          pkg = pkgs.obsidianPlugins.dataview;
        }
        {
          pkg = pkgs.obsidianPlugins.obsidian-vimrc-support;
        }
        {
          pkg = pkgs.obsidianPlugins.obsidian-relative-line-numbers;
        }
        {
          pkg = pkgs.obsidianPlugins.obsidian-style-settings;
          settings = {
            "catppuccin-theme-settings@@catppuccin-theme-accents" = "ctp-accent-red";
          };
        }
        {
          pkg = pkgs.obsidianPlugins.homepage;
          settings = {
            version = 4;
            separateMobile = true;
            homepages = {
              "Main Homepage" = {
                value = "Kanban";
                kind = "File";
                openOnStartup = true;
                openMode = "Replace all open notes";
                manualOpenMode = "Keep open notes";
                view = "Default view";
                revertView = true;
                autoCreate = false;
                autoScroll = false;
                openWhenEmpty = false;
                refreshDataview = false;
                pin = false;
                commands = [];
                alwaysApply = false;
                hideReleaseNotes = false;
              };
            };
          };
        }
        {
          pkg = pkgs.obsidianPlugins.obsidian-git;
          settings = {
            commitMessage = "vault backup: {{date}}";
            autoCommitMessage = "vault backup: {{date}}";
            commitMessageScript = "";
            commitDateFormat = "YYYY-MM-DD HH:mm:ss";
            autoSaveInterval = 240;
            autoPushInterval = 240;
            autoPullInterval = 0;
            autoPullOnBoot = false;
            autoCommitOnlyStaged = false;
            disablePush = false;
            pullBeforePush = true;
            disablePopups = false;
            showErrorNotices = true;
            disablePopupsForNoChanges = false;
            listChangedFilesInMessageBody = false;
            showStatusBar = true;
            updateSubmodules = false;
            syncMethod = "merge";
            customMessageOnAutoBackup = false;
            autoBackupAfterFileChange = false;
            treeStructure = false;
            refreshSourceControl = true;
            basePath = "";
            differentIntervalCommitAndPush = true;
            changedFilesInStatusBar = false;
            showedMobileNotice = true;
            refreshSourceControlTimer = 7000;
            showBranchStatusBar = true;
            setLastSaveToLastCommit = false;
            submoduleRecurseCheckout = false;
            gitDir = "";
            showFileMenu = true;
            authorInHistoryView = "hide";
            dateInHistoryView = false;
            diffStyle = "split";
            lineAuthor = {
              show = false;
              followMovement = "inactive";
              authorDisplay = "initials";
              showCommitHash = false;
              dateTimeFormatOptions = "date";
              dateTimeFormatCustomString = "YYYY-MM-DD HH:mm";
              dateTimeTimezone = "viewer-local";
              coloringMaxAge = "1y";
              colorNew = {
                r = 255;
                g = 150;
                b = 150;
              };
              colorOld = {
                r = 120;
                g = 160;
                b = 255;
              };
              textColorCss = "var(--text-muted)";
              ignoreWhitespace = false;
              gutterSpacingFallbackLength = 5;
              lastShownAuthorDisplay = "initials";
              lastShownDateTimeFormatOptions = "date";
            };
          };
        }
        {
          pkg = pkgs.obsidianPlugins.obsidian-tasks-plugin;
          settings = {
            includes = {};
            globalQuery = "";
            globalFilter = "";
            removeGlobalFilter = false;
            taskFormat = "tasksPluginEmoji";
            setCreatedDate = false;
            setDoneDate = true;
            setCancelledDate = true;
            autoSuggestInEditor = true;
            autoSuggestMinMatch = 0;
            autoSuggestMaxItems = 20;
            provideAccessKeys = true;
            useFilenameAsScheduledDate = false;
            filenameAsScheduledDateFormat = "";
            filenameAsDateFolders = [];
            recurrenceOnNextLine = false;
            removeScheduledDateOnRecurrence = false;
            statusSettings = {
              coreStatuses = [
                {
                  symbol = " ";
                  name = "Todo";
                  nextStatusSymbol = "x";
                  availableAsCommand = true;
                  type = "TODO";
                }
                {
                  symbol = "x";
                  name = "Done";
                  nextStatusSymbol = " ";
                  availableAsCommand = true;
                  type = "DONE";
                }
              ];
              customStatuses = [
                {
                  symbol = "/";
                  name = "In Progress";
                  nextStatusSymbol = "x";
                  availableAsCommand = true;
                  type = "IN_PROGRESS";
                }
                {
                  symbol = "-";
                  name = "Cancelled";
                  nextStatusSymbol = " ";
                  availableAsCommand = true;
                  type = "CANCELLED";
                }
              ];
            };
            features = {
              INTERNAL_TESTING_ENABLED_BY_DEFAULT = true;
            };
            generalSettings = {};
            headingOpened = {
              "Core Statuses" = true;
              "Custom Statuses" = true;
            };
            debugSettings = {
              ignoreSortInstructions = false;
              showTaskHiddenData = false;
              recordTimings = false;
            };
            loggingOptions = {
              minLevels = {
                "" = "info";
                "tasks" = "info";
                "tasks.Cache" = "info";
                "tasks.Events" = "info";
                "tasks.File" = "info";
                "tasks.Query" = "info";
                "tasks.Task" = "info";
              };
            };
          };
        }
      ];
    };
  };
}

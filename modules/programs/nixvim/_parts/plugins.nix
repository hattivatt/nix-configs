{
  plugins = {
    lualine.enable = true;
    commentary.enable = true;
    web-devicons.enable = true;
    hop.enable = true;
    yazi.enable = true;
    gitsigns.enable = true;
    fugitive.enable = true;
    friendly-snippets.enable = true;
    luasnip = {
      enable = true;
      filetypeExtend = {
        jjdescription = [ "gitcommit" ];
      };
    };
    blink-cmp = {
      enable = true;
      settings = {
        # sources.providers = {
        #   snippets.opts = {
        #     extended_filetypes = {
        #       jjdescription = [ "gitcommit" ];
        #     };
        #   };
        # };
        snippets.preset = "luasnip";
        sources.default = [
          "path"
          "snippets"
          "lsp"
          "buffer"
        ];
      };
    };
    endec = {
      enable = true;
      settings.keymaps = {
        defaults = true;
      };
    };
    treesitter = {
      enable = true;
      highlight.enable = true;
      indent.enable = true;
    };
    dashboard = {
      enable = true;
      settings = {
        theme = "doom";
        config = {
          week_header = {
            enable = true;
          };
          center = [
            {
              icon = "E ";
              icon_hl = "Title";
              desc = "Empty File           ";
              desc_hl = "String";
              key = "e";
              key_hl = "Number";
              key_format = " %s";
              action = "enew";
            }
            {
              icon = "S ";
              desc = "Search Current dir";
              key = "s";
              key_format = " %s";
              action = "Telescope live_grep";
            }
          ];
        };
      };
    };
    indent-blankline = {
      enable = true;
      settings = {
        exclude = {
          filetypes = [ "dashboard" ];
        };
      };
    };
    telescope = {
      enable = true;
      extensions = {
        ui-select.enable = true;
      };
    };
    obsidian = {
      enable = true;
      settings = {
        workspaces = [
          {
            name = "personal";
            path = "/home/hattivatt/Notes/ObsidianNotes";
          }
        ];
        legacy_commands = false;
        new_notes_location = "1Inbox";
        picker = {
          name = "telescope.nvim";
          note_mappings = {
            new = "<C-x>";
            insert_link = "<C-l>";
          };
          tag_mappings = {
            tag_note = "<C-x>";
            insert_tag = "<C-l>";
          };
        };
        ui = {
          enable = true;
          ignore_conceal_warn = false;
          update_debounce = 200;
          max_file_length = 5000;
        };
        templates = {
          folder = "Templates";
          date_format = "%Y-%m-%d-%a";
          time_format = "%H:%M";
          customizations = {
            task_tpl.notes_subdir = "work";
            meeting_tpl.notes_subdir = "work";
            zk_template.notes_subdir = "zettelkasten";
          };
        };
      };
    };
  };
}

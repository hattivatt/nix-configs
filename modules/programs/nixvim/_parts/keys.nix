{
  keymaps = [
    # Gitsigns
    {
      mode = "n";
      key = "<leader>hs";
      action = "<cmd>Gitsigns stage_hunk<cr>";
      options.desc = "Stage hunk";
    }
    {
      mode = "n";
      key = "<leader>hr";
      action = "<cmd>Gitsigns reset_hunk<cr>";
      options.desc = "Reset hunk";
    }
    {
      mode = "n";
      key = "<leader>hS";
      action = "<cmd>Gitsigns reset_buffer<cr>";
      options.desc = "Stage buffer";
    }
    {
      mode = "n";
      key = "<leader>hu";
      action = "<cmd>Gitsigns undo_stage_hunk<cr>";
      options.desc = "Undo stage hunk";
    }
    {
      mode = "n";
      key = "<leader>hR";
      action = "<cmd>Gitsigns reset_buffer<cr>";
      options.desc = "Reset buffer";
    }
    {
      mode = "n";
      key = "<leader>hp";
      action = "<cmd>Gitsigns preview_hunk<cr>";
      options.desc = "Preview hunk";
    }
    {
      mode = "n";
      key = "<leader>tb";
      action = "<cmd>Gitsigns toggle_current_line_blame<cr>";
      options.desc = "Toggle git blame in line";
    }
    {
      mode = "n";
      key = "<leader>hd";
      action = "<cmd>Gitsigns diffthis<cr>";
      options.desc = "Show diff";
    }
    {
      mode = "n";
      key = "<leader>td";
      action = "<cmd>Gitsigns toggle_deleted<cr>";
      options.desc = "Toggle deleted";
    }
    # Fugitive
    {
      mode = "n";
      key = "<leader>gs";
      action = "<cmd>Git status<cr>";
      options.desc = "git status";
    }
    {
      mode = "n";
      key = "<leader>gpl";
      action = "<cmd>Git pull<cr>";
      options.desc = "git pull";
    }
    {
      mode = "n";
      key = "<leader>ga";
      action = "<cmd>Git add .<cr>";
      options.desc = "git add";
    }
    {
      mode = "n";
      key = "<leader>gc";
      action = "<cmd>Git commit<cr>";
      options.desc = "git commit";
    }
    {
      mode = "n";
      key = "<leader>gph";
      action = "<cmd>Git push<cr>";
      options.desc = "git push";
    }
    {
      mode = "n";
      key = "<leader>gg";
      action = "<cmd>Git<cr>";
      options.desc = "Fugitive interactive";
    }
    #Hop
    {
      mode = "";
      key = "f";
      action = "<cmd>HopChar1AC<cr>";
      options.desc = "Hop after cursor";
    }
    {
      mode = "";
      key = "F";
      action = "<cmd>HopChar1BC<cr>";
      options.desc = "Hop before cursor";
    }
    #Lsp
    {
      mode = "n";
      key = "K";
      action = "<cmd>lua vim.lsp.buf.hover()<cr>";
      options.desc = "Show LSP info";
    }
    {
      mode = "n";
      key = "gd";
      action = "<cmd>lua vim.lsp.buf.definition()<cr>";
      options.desc = "Show LSP info";
    }
    {
      mode = [ "n" "v"];
      key = "<leader>ca";
      action = "<cmd>lua vim.lsp.buf.code_action()<cr>";
      options.desc = "Show LSP info";
    }
    #Telecope
    {
      mode = "n";
      key = "<C-p>";
      action = "<cmd>Telescope find_files<cr>";
      options.desc = "Find files in current project";
    }
    {
      mode = "n";
      key = "<leader>fg";
      action = "<cmd>Telescope live_grep<cr>";
      options.desc = "Find lines in content of current dir";
    }
    {
      mode = "n";
      key = "<leader>ls";
      action = "<cmd>Telescope buffers<cr>";
      options.desc = "Search buffets";
    }
    {
      mode = "n";
      key = "<leader><leader>";
      action = "<cmd>Telescope commands<cr>";
      options.desc = "Search commands";
    }
    {
      mode = "n";
      key = "<leader>ff";
      action = "<cmd>Obsidian search<cr>";
      options.desc = "Find lines in notes";
    }
    {
      mode = "n";
      key = "<leader>ot";
      action = "<cmd>Obsidian tags<cr>";
      options.desc = "Search obsidian tags";
    }
    {
      mode = "n";
      key = "<leader>os";
      action = "<cmd>Obsidian quick_switch<cr>";
      options.desc = "Switch between obsidian notes";
    }
    #Yazi
    {
      mode = "n";
      key = "<C-n>";
      action = "<cmd>Yazi<cr>";
      options.desc = "Open yazi at the current file";
    }
  ];
}

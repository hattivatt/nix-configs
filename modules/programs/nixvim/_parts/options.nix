{
  colorschemes.catppuccin = {
    enable = true;
    settings = {
      background.dark = "mocha";
      flavour = "mocha";
      transparent_background = true;
    };
  };
  clipboard.register = "unnamedplus";
  globalOpts = {
    termguicolors = true;
  };
  opts = {
    encoding = "utf-8";
    fileencodings = "utf-8,euc-kr";
    number = true;
    relativenumber = true;
    cursorline = true;
    cursorcolumn = true;
    undofile = true;
    title = true;
    expandtab = true;
    tabstop = 2;
    softtabstop = 2;
    shiftwidth = 2;
    ignorecase = true;
    conceallevel = 2;
  };
  globals.mapleader = " ";
  autoCmd = [
  {
    event = [
      "BufWritePre"
    ];
    pattern = [
      "*"
    ];
    callback = {
      __raw = ''
      function(ev)
        save_cursor = vim.fn.getpos(".")
        vim.cmd([[%s/\s\+$//e]])
        vim.fn.setpos(".", save_cursor)
      end
      '';
    };
  }
  {
    event = [
      "FileType"
    ];
    pattern = [
      "hcl"
    ];
    callback = {
      __raw = ''
      function(args)
        vim.opt_local.commentstring = "# %s"
      end
      '';
    };
  }
];
}

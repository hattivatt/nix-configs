{
  plugins = {
    lspconfig.enable = true;
  };
  lsp = {
    servers = {
      lua_ls.enable = true;
      bashls.enable = true;
      helm_ls.enable = true;
      jsonls.enable = true;
      taplo.enable = true;
      terraformls.enable = true;
      yamlls.enable = true;
      gopls.enable = true;
      marksman.enable = true;
    };
  };
}

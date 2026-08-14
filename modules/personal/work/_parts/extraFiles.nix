{ config, ... }:
{
  sops = {
    secrets.sc_json = { };
    secrets.nu_tfenv = { };
    secrets."vcs/work_jj" = { };
  };
  home.file = {
    "sbercloud.json".source = config.lib.file.mkOutOfStoreSymlink config.sops.secrets.sc_json.path;
    ".tfenv.nu".source = config.lib.file.mkOutOfStoreSymlink config.sops.secrets.nu_tfenv.path;
  };
  xdg.configFile = {
    "jj/conf.d/work.toml".source = config.lib.file.mkOutOfStoreSymlink config.sops.secrets."vcs/work_jj".path;
  };
}

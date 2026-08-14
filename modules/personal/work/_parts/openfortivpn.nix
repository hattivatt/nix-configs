{ config, ... }:
{
  sops = {
    secrets.forti_host1 = { };
    secrets.forti_host2 = { };
    secrets.forti_user = { };
    secrets.forti_cert = { };
    templates.openfortivpn-config = {
      content = ''
        host = ${config.sops.placeholder.forti_host1}
        port=10443
        trusted-cert=${config.sops.placeholder.forti_cert}
        username=${config.sops.placeholder.forti_user}
      '';
    };
    templates.openfortivpn-config-res = {
      content = ''
        host = ${config.sops.placeholder.forti_host2}
        port=10443
        trusted-cert=${config.sops.placeholder.forti_cert}
        username=${config.sops.placeholder.forti_user}
      '';
    };
  };
xdg.configFile."openfortivpn/config".source =
    config.lib.file.mkOutOfStoreSymlink config.sops.templates.openfortivpn-config.path;
xdg.configFile."openfortivpn/config-res".source =
    config.lib.file.mkOutOfStoreSymlink config.sops.templates.openfortivpn-config-res.path;
}

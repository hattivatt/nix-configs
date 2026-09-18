{
  flake.modules.nixos.caddy =
  { pkgs, ... }:
  {
    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
        hash = "sha256-0Csi6WmyoGj7bXeo2Lrnwr0SCoV6c/niymtOp5DdiT4=";
      };
    };
  };
}

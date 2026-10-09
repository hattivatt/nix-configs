{
  flake.modules.nixos.koinsight =
  { ... }:
  {
    services.koinsight = {
      enable = true;
      port = 3228;
    };
  };
}

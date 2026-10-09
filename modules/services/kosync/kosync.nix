{
  flake.modules.nixos.kosync =
  { inputs, ... }:
  {
    imports = [
      inputs.kosync.nixosModules."x86_64-linux".default
    ];
    services.kosync = {
      enable = true;
      dbPath = "/var/lib/kosync/kosync.db";
      port = 7200;
      host = "127.0.0.1";
      user = "kosync";
      group = "kosync";
    };
  };
}

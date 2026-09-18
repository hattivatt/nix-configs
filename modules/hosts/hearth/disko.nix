{ inputs, ... }:
{
  flake.modules.nixos.hearth = {
    imports = with inputs.self.modules.nixos; [
      disko-simple-imp-btrfs
    ];
    disko.devices.disk.main = {
      device = "/dev/vda";
      content.partitions = {
        ESP.size = "512M";
      };
    };
  };
}


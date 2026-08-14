{ inputs, ... }:
{
  flake.modules.nixos.hearth = {
    imports = with inputs.self.modules.nixos; [
      disko-imp-luks-btrfs-subvol
    ];
    disko.devices.disk.main = {
      device = "/dev/vda";
      content.partitions = {
        ESP.size = "512M";
        luks.content.content.subvolumes."@swap".swap.swapfile.size = "2G";
      };
    };
  };
}


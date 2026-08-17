{ inputs, ... }:
{
  flake.modules.nixos.thevalley = {
    imports = with inputs.self.modules.nixos; [
      disko-imp-luks-btrfs-subvol
    ];
    disko.devices.disk.main = {
      device = "/dev/disk/by-id/nvme-SSSTC_CL1-4D512_SS0Z26652L1TH13802VX";
      content.partitions = {
        ESP.size = "2G";
        luks.content.content.subvolumes."@swap".swap.swapfile.size = "8G";
      };
    };
  };
}


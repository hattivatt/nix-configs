{ inputs, ... }:
{
  flake.modules.nixos.disko-luks-btrfs-subvol =
  {
    imports = with inputs.self.modules.nixos; [
      disko-common
    ];
    boot.loader.efi.canTouchEfiVariables = true;
    boot.initrd.luks.devices."crypted" = {
      device = "/dev/disk/by-partlabel/disk-main-luks";
      preLVM = true;
      allowDiscards = true;
      bypassWorkqueues = true;
    };
    disko.devices.disk.main.content.partitions.luks = {
      size = "100%";
      content = {
        type = "luks";
        name = "crypted";
        passwordFile = "/tmp/secret.key"; # Interactive
        settings = {
          allowDiscards = true;
        };
        content = {
          type = "btrfs";
          extraArgs = [ "-f" ];
          subvolumes = {
            "/root" = {
              mountpoint = "/";
              mountOptions = [
                "compress=zstd"
                "noatime"
              ];
            };
            "/home" = {
              mountpoint = "/home";
              mountOptions = [
                "compress=zstd"
                "noatime"
              ];
            };
            "/nix" = {
              mountpoint = "/nix";
              mountOptions = [
                "compress=zstd"
                "noatime"
              ];
            };
            "/swap" = {
              mountpoint = "/.swapvol";
            };
          };
        };
      };
    };
  };
}

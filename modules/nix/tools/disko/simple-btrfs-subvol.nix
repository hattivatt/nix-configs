{ inputs, ... }:
{
  flake.modules.nixos.disko-simple-btrfs-subvol =
  {
    imports = with inputs.self.modules.nixos; [
      disko-common
    ];
    disko.devices.disk.main.content.partitions.root = {
      size = "100%";
      content = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        mountpoint = "/partition-root";
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
}

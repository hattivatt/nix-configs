{ inputs, ... }:
{
  flake.modules.nixos.disko-simple-imp-btrfs =
  {
    imports = with inputs.self.modules.nixos; [
      disko-common
    ];
    fileSystems."/persist".neededForBoot = true;
    fileSystems."/nix".neededForBoot = true;
    disko.devices.nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=25%"
          "mode=755"
        ];
      };
    };
    disko.devices.disk.main.content.partitions.root = {
      size = "100%";
      content = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        subvolumes = {
          "/persist" = {
            mountpoint = "/persist";
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
        };
      };
    };
  };
}

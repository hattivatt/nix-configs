{ inputs, ... }:
{
  flake.modules.nixos.disko-common =
  { pkgs, ... }:
  {
    imports = [
      inputs.disko.nixosModules.disko
    ];
    environment.systemPackages = with pkgs; [
      btrfs-progs
    ];
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
            };
          };
        };
      };
    };
  };
}

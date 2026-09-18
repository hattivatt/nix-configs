{
  flake.modules.nixos.disko-imp-luks-btrfs-subvol =
  {
    my.persist.files = [
      {
        file = "/etc/machine-id";
        inInitrd = true;
        how = "symlink";
        configureParent = true;
      }
    ];
  };
}

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
    my.persist.directories = [
      "/etc/ssh"
    ];
  };
  flake.modules.nixos.disko-simple-imp-btrfs =
  {
    my.persist.files = [
      {
        file = "/etc/ssh/ssh_host_ed25519_key";
        how = "symlink";
        configureParent = true;
      }
      {
        file = "/etc/ssh/ssh_host_ed25519_key.pub";
        how = "symlink";
        configureParent = true;
      }
      {
        file = "/etc/ssh/ssh_host_rsa_key";
        how = "symlink";
        configureParent = true;
      }
      {
        file = "/etc/ssh/ssh_host_rsa_key.pub";
        how = "symlink";
        configureParent = true;
      }
    ];
  };
}

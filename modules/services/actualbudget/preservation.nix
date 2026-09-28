{
  flake.modules.nixos.actualbudget =
  {
    my.persist.directories = [
      "/var/lib/actual"
    ];
  };
}

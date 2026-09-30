{ pkgs, lib }:
pkgs.writers.writeNuBin "callrec" {
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ pkgs.fzf pkgs.pipewire ])
  ];
} (builtins.readFile ./callrec.nu)

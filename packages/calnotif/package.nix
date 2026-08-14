{ pkgs }:
pkgs.writers.writeNuBin "calnotif" (builtins.readFile ./calnotif.nu)

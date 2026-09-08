{ pkgs }:
pkgs.writers.writeNuBin "mailnotif" (builtins.readFile ./mailnotif.nu)

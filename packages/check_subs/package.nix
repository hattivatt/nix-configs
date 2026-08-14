{ pkgs }:
pkgs.writers.writePython3Bin "check_subs" {} (builtins.readFile ./check_subs.py)

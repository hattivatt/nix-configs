{ pkgs, lib }:
pkgs.writers.writePython3Bin "booktest" { } (builtins.readFile ./booktest.py)

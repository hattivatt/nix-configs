{ pkgs, lib }:
pkgs.writers.writePython3Bin "rpr" {
  libraries = with pkgs.python3Packages; [ pyperclip ];
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${lib.makeBinPath [ pkgs.wl-clipboard ]}"
  ];
} (builtins.readFile ./rpr.py)

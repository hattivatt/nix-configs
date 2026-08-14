{ pkgs, lib }:
pkgs.writeShellApplication {
  name = "zkn";
  text = builtins.readFile ./zkn.sh;
}

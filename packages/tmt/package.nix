{ pkgs }:
pkgs.writeShellApplication {
  name = "tmt";
  text = builtins.readFile ./tmt.sh;
}

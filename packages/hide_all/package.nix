{ pkgs }:
pkgs.writeShellApplication {
  name = "hide_all";
  text = builtins.readFile ./hide_all.sh;
}

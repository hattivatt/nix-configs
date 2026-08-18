{ pkgs }:
pkgs.writeShellApplication {
  name = "rebuild";
  text = builtins.readFile ./rebuild.sh;
}

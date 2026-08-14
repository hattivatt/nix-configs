{ pkgs }:
pkgs.writeShellApplication {
  name = "change_wp";
  text = builtins.readFile ./change_wp.sh;
}

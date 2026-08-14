{ pkgs }:
pkgs.writeShellApplication {
  name = "medialist";
  runtimeInputs = with pkgs; [ fuzzel ];
  text = builtins.readFile ./medialist.sh;
}

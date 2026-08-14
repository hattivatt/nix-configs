{ pkgs, lib }:
pkgs.writeShellApplication {
  name = "mergesubs";
  runtimeInputs = with pkgs; [ mkvtoolnix-cli ];
  text = builtins.readFile ./mergesubs.sh;
}

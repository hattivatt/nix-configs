{ pkgs }:
pkgs.writeShellApplication {
  name = "downloads_clear";
  runtimeInputs = with pkgs; [ trash-cli ];
  text = builtins.readFile ./downloads_clear.sh;
}

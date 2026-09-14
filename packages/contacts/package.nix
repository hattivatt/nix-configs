{ pkgs }:
pkgs.writeShellApplication {
  name = "contacts";
  runtimeInputs = with pkgs; [ fuzzel khard wl-clipboard ];
  text = builtins.readFile ./contacts.sh;
}

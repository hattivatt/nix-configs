{ pkgs }:
pkgs.writeShellApplication {
  name = "device-manager";
  runtimeInputs = with pkgs; [ fuzzel networkmanager ];
  text = builtins.readFile ./device-manager.sh;
}

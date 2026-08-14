{ pkgs }:
pkgs.writeShellApplication {
  name = "workbackup";
  runtimeInputs = with pkgs; [ rsync ];
  text = builtins.readFile ./workbackup.sh;
}

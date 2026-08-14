{ pkgs }:
pkgs.writeShellApplication {
  name = "vaultsearch";
  runtimeInputs = with pkgs; [ fuzzel fzf vault-bin wl-clipboard ];
  text = builtins.readFile ./vaultsearch.sh;
}

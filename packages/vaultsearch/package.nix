{ pkgs }:
pkgs.writeShellApplication {
  name = "vaultsearch";
  runtimeInputs = with pkgs; [ fuzzel fzf vault-bin wl-clipboard jq ];
  text = builtins.readFile ./vaultsearch.sh;
}

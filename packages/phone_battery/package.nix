{ pkgs }:
pkgs.writeShellApplication {
  name = "phone_battery";
  runtimeInputs = with pkgs; [ kdePackages.kdeconnect-kde kdePackages.qttools ];
  text = builtins.readFile ./phone_battery.sh;
}

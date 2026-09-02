{
  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist".users.hattivatt.directories = [
      ".config/pi"
      ".config/opencode"
      ".config/autolith"
      ".local/share/opencode"
      ".local/share/autolith"
      ".local/share/clankerland"
      ".local/share/opentui"
      ".local/state/autolith"
      ".local/state/opencode"
    ];
  };
}

{
  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist".users.hattivatt.directories = [
      ".config/pi"
      ".config/opencode"
    ];
  };
}

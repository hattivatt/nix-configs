{
  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist".users.hattivatt.files = [
      ".cache/fuzzel"
    ];
  };
}

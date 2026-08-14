{
  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist".users.hattivatt.directories = [
      ".config/FBReader.ORG Limited"
    ];
  };
}

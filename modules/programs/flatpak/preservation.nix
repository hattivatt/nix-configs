{
  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist".directories = [
      "/var/lib/flatpak"
    ];
    preservation.preserveAt."/persist".users.hattivatt.directories = [
      ".var/app"
    ];
  };
}

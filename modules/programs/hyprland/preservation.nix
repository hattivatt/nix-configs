{
  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist".users.hattivatt.directories = [
      {
        directory = ".local/share/hyprland";
        mode = "0700";
      }
    ];
  };
}

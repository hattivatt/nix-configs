{
  flake.modules.nixos.flatpak = {
    my.persist.directories = [
      "/var/lib/flatpak"
    ];
  };
  flake.modules.homeManager.flatpak = {
    my.persist.directories = [
      ".var/app"
      {
        directory = ".local/share/flatpak";
        mode = "0700";
      }
    ];
  };
}

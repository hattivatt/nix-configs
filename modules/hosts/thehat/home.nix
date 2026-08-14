{ inputs, ... }:
{
  flake.modules.homeManager.thehat =
    { config, pkgs, lib, ... }:
    {
      home.username = "hattivatt";
      services.gnome-keyring.enable = lib.mkForce false;
      systemd.user.startServices = false;
      nixpkgs.config.allowUnfree = true;
      imports = with inputs.self.modules.homeManager; [
        system-desktop
        accounts
        keys
        work
      ];
    };
}

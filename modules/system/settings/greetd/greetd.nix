{
  flake.modules.nixos.greetd =
  { pkgs, config, ... }:
  {
    environment.systemPackages = with pkgs; [
      tuigreet
    ];
    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings = {
        default_session.command = "${pkgs.tuigreet}/bin/tuigreet -r --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --remember-session --asterisks";
      };
    };
  };
}

{
  flake.modules.homeManager.agents = {
    my.persist.directories = [
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
  flake.modules.nixos.hermes = {
    my.persist.directories = [
      {
        directory = "/var/lib/hermes";
        group = "hermes";
        user = "hermes";
        configureParent = true;
        parent = {
          group = "hermes";
          user = "hermes";
        };
      }
    ];
  };
}

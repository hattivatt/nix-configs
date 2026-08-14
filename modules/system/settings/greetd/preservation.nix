{
  flake.modules.nixos.preservation = {
    preservation.preserveAt."/persist".directories = [
      {
        directory = "/var/cache/tuigreet";
        group = "greeter";
        user = "greeter";
        configureParent = true;
        parent = {
          group = "greeter";
          user = "greeter";
        };
      }
    ];
  };
}


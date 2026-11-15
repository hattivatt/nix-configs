{
  flake.modules.nixos.campaign-bot = {
    my.persist.directories = [
      {
        directory = "/var/lib/campaign-bot";
        group = "campaign-bot";
        user = "campaign-bot";
      }
    ];
  };
}

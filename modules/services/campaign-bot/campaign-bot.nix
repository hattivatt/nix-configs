{
  flake.modules.nixos.campaign-bot =
    { config, ... }:
    {
      sops.secrets.campaign_bot_discord_token = {
        restartUnits = [ "campaign-bot.service" ];
      };
      sops.secrets.campaign_bot_opencode_key = {
        restartUnits = [ "campaign-bot.service" ];
      };
      sops.secrets.campaign_bot_foundry_password = {
        restartUnits = [ "campaign-bot.service" ];
      };
      sops.templates."campaign-bot.env" = {
        content = ''
          DISCORD_TOKEN=${config.sops.placeholder.campaign_bot_discord_token}
          OPENCODE_API_KEY=${config.sops.placeholder.campaign_bot_opencode_key}
          FOUNDRY_PASSWORD=${config.sops.placeholder.campaign_bot_foundry_password}
        '';
      };

      services.campaign-bot = {
        enable = true;
        stateDir = "/var/lib/campaign-bot";
        environmentFile = config.sops.templates."campaign-bot.env".path;
        foundryData.root = "/home/hattivatt/.local/share/FoundryVTT";
        settings.llm = {
          base_url = "https://opencode.ai/inference/go/openai/v1";
          model = "deepseek-v4.1-flash";
          max_steps = 40;
          timeout_ms = 900000;
        };
      };
    };
}

{
  flake.modules.nixos.server-apps =
  { pkgs, ... }:
  {
    environment.systemPackages = with pkgs; [
    ];
  };
  flake.modules.homeManager.server-apps =
  { pkgs, config, ... }:
  {
    home.packages = with pkgs; [
      net-tools
      sbcl
    ];
    sops = {
      secrets."al/tg" = { };
      secrets."al/discord" = { };
    };
    xdg.configFile = {
      "al-gateway/secrets/telegram.token".source = config.lib.file.mkOutOfStoreSymlink config.sops.secrets."al/tg".path;
      "al-gateway/secrets/discord.token".source = config.lib.file.mkOutOfStoreSymlink config.sops.secrets."al/discord".path;
    };
    programs.nushell.extraEnv = ''
      $env.AL_TELEGRAM_TOKEN = (open ${config.sops.secrets."al/tg".path} | str trim)
      $env.AL_DISCORD_TOKEN = (open ${config.sops.secrets."al/discord".path} | str trim)
    '';
  };
}

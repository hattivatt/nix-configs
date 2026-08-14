{
  flake.modules.homeManager.zen-browser =
  { inputs, pkgs, ... }:
  {
    imports = [
      inputs.zen-browser.homeModules.beta
      ./_parts/settings.nix
      ./_parts/theme.nix
      ./_parts/policies.nix
      ./_parts/extensions.nix
    ];
    programs.zen-browser = {
      enable = true;
      nativeMessagingHosts = [pkgs.browserpass];
      profiles."default" = {
        mods = [
          "a5f6a231-e3c8-4ce8-8a8e-3e93efd6adec"
          "c01d3e22-1cee-45c1-a25e-53c0f180eea8"
          "1b88a6d1-d931-45e8-b6c3-bfdca2c7e9d6"
          "ad97bb70-0066-4e42-9b5f-173a5e42c6fc"
        ];
      };
    };
  };
}

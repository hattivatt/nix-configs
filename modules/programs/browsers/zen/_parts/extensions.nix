{
  programs.zen-browser.policies  = let
    mkExtensionSettings = builtins.mapAttrs (_: pluginId: {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
      installation_mode = "force_installed";
    });
  in {
    ExtensionSettings = mkExtensionSettings {
      "browserpass@maximbaz.com" = "browserpass-ce";
      "sponsorBlocker@ajay.app" = "sponsorblock";
      "uBlock0@raymondhill.net" = "ublock-origin";
      "vimium-c@gdh1995.cn" = "vimium-c";
      "@windscribeff" = "windscribe";
      "{bd6be57d-91d7-41d2-b61d-3ba20f7942e5}" = "kagi-translate";
    };
  };
}

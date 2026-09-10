{
  flake.modules.homeManager.mime = {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/discord" = "vesktop.desktop";
        "x-scheme-handler/slack" = "slack.desktop";
        "x-scheme-handler/http" = "zen-beta.desktop";
        "x-scheme-handler/https" = "zen-beta.desktop";
        "x-scheme-handler/chrome" = "zen-beta.desktop";
        "text/html" = "zen-beta.desktop";
        "application/x-extension-htm" = "zen-beta.desktop";
        "application/x-extension-html" = "zen-beta.desktop";
        "application/x-extension-shtml" = "zen-beta.desktop";
        "application/xhtml+xml" = "zen-beta.desktop";
        "application/x-extension-xhtml" = "zen-beta.desktop";
        "application/x-extension-xht" = "zen-beta.desktop";
        "image/png" = "imv.desktop";
        "image/x-png" = "imv.desktop";
        "image/jpeg" = "imv.desktop";
        "image/jpg" = "imv.desktop";
        "image/pjpeg" = "imv.desktop";
        "image/gif" = "imv.desktop";
        "image/webp" = "imv.desktop";
        "image/bmp" = "imv.desktop";
        "image/x-bmp" = "imv.desktop";
        "image/tiff" = "imv.desktop";
        "image/tiff-fx" = "imv.desktop";
        "image/svg+xml" = "imv.desktop";
        "image/avif" = "imv.desktop";
        "image/heif" = "imv.desktop";
        "image/jxl" = "imv.desktop";
        "image/qoi" = "imv.desktop";
        "image/x-farbfeld" = "imv.desktop";
        "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
      };
      associations.added = {
        "x-scheme-handler/slack" = "slack.desktop";
        "x-scheme-handler/http" = "zen-beta.desktop";
        "x-scheme-handler/https" = "zen-beta.desktop";
        "x-scheme-handler/chrome" = "zen-beta.desktop";
        "text/html" = "zen-beta.desktop";
        "application/x-extension-htm" = "zen-beta.desktop";
        "application/x-extension-html" = "zen-beta.desktop";
        "application/x-extension-shtml" = "zen-beta.desktop";
        "application/xhtml+xml" = "zen-beta.desktop";
        "application/x-extension-xhtml" = "zen-beta.desktop";
        "application/x-extension-xht" = "zen-beta.desktop";
      };
    };
  };
}

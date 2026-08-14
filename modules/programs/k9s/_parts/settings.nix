{
  programs.k9s.settings = {
    k9s = {
      liveViewAutoRefresh = false;
      screenDumpDir = "/home/hattivatt/.local/state/k9s/screen-dumps";
      refreshRate = 2;
      maxConnRetry = 5;
      readOnly = false;
      noExitOnCtrlC = true;
      defaultView = "pods";
      ui = {
        enableMouse = false;
        headless = false;
        logoless = false;
        crumbsless = false;
        reactive = false;
        noIcons = false;
        defaultsToFullScreen = false;
      };
      skipLatestRevCheck = false;
      disablePodCounting = false;
      shellPod = {
        image = "alpine:3.19";
        namespace = "default";
        limits = {
          cpu = "100m";
          memory = "100Mi";
        };
      };
      imageScans = {
        enable = false;
        exclusions = {
          namespaces = "[]";
          labels = "{}";
        };
      };
      logger = {
        tail = 1000;
        buffer = 5000;
        sinceSeconds = 600;
        textWrap = true;
        showTime = false;
      };
      thresholds = {
        cpu = {
          critical = 90;
          warn = 70;
        };
        memory = {
          critical = 90;
          warn = 70;
        };
      };
    };
  };
}

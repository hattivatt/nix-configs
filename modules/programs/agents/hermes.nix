{
  flake.modules.nixos.hermes =
  { inputs, config, ... }:
  {
    imports = [
      inputs.hermes-agent.nixosModules.default
    ];
    sops = {
      secrets."hermes-env" = { };
    };
    services.hermes-agent = {
      enable = true;
      environmentFiles = [ config.sops.secrets."hermes-env".path ];
      addToSystemPackages = true;
      container.enable = true;
      container.hostUsers = [ "hattivatt" ];
      container.extraVolumes = [
          "/var/lib/cwa-ingest:/var/lib/cwa-ingest:rw"
          "/home/hattivatt/.local/share/FoundryVTT:/data/FoundryVTT:rw"
      ];
      settings = {
        model.default = "opencode-go/deepseek-v4.1-flash";
        mode.base_url = "https://opencode.ai/zen/go/v1/responses";
        timezone = "Asia/Ho_Chi_Minh";
      };
      workingDirectory = "/var/lib/hermes/workspace";
      hermesHomeFiles."SOUL.md" = ./hermes/SOUL.md;
      documents."AGENTS.md" = ./hermes/AGENTS.md;
      mcpServers = {
        actual-budget-mcp-usd = {
          command = "/usr/bin/npx";
          args = ["-y" "actual-budget-mcp"];
          env = {
            ACTUAL_SERVER_URL = "http://localhost:3000";
            ACTUAL_PASSWORD = "\${ACTUAL_PASSWORD}";
            ACTUAL_BUDGET_ID = "2250610e-de2a-4dd0-9c00-cc53702aafa4";
            PATH = "/usr/bin:/bin";
          };
        };
        actual-budget-mcp-rub = {
          command = "/usr/bin/npx";
          args = ["-y" "actual-budget-mcp"];
          env = {
            ACTUAL_SERVER_URL = "http://localhost:3000";
            ACTUAL_PASSWORD = "\${ACTUAL_PASSWORD}";
            ACTUAL_BUDGET_ID = "b9264161-5733-469f-86e7-21001c25c7d4";
            PATH = "/usr/bin:/bin";
          };
        };
        actual-budget-mcp-vnd = {
          command = "/usr/bin/npx";
          args = ["-y" "actual-budget-mcp"];
          env = {
            ACTUAL_SERVER_URL = "http://localhost:3000";
            ACTUAL_PASSWORD = "\${ACTUAL_PASSWORD}";
            ACTUAL_BUDGET_ID = "243173ea-33e3-4d68-88e6-5754f68a3aa0";
            PATH = "/usr/bin:/bin";
          };
        };
        actual-budget-mcp-myr = {
          command = "/usr/bin/npx";
          args = ["-y" "actual-budget-mcp"];
          env = {
            ACTUAL_SERVER_URL = "http://localhost:3000";
            ACTUAL_PASSWORD = "\${ACTUAL_PASSWORD}";
            ACTUAL_BUDGET_ID = "e5fe64a8-24d0-48ec-86c0-a18854650232";
            PATH = "/usr/bin:/bin";
          };
        };
        hardcover = {
          command = "uvx";
          args = ["hardcover-mcp"];
          env = {
            HARDCOVER_API_TOKEN = "\${HARDCOVER_API_TOKEN}";
          };
        };
        storygraph = {
          command = "/usr/bin/node";
          args = ["/home/hermes/mcp/storygraph-mcp/dist/index.js"];
          env = {
            STORYGRAPH_USERNAME = "hattivatt";
            STORYGRAPH_SESSION_COOKIE = "\${STORYGRAPH_SESSION_COOKIE}";
          };
        };
      };
    };
  };
}

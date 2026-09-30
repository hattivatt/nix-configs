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
      settings = {
        model.default = "opencode-go/deepseek-v4.1-flash";
        mode.base_url = "https://opencode.ai/zen/go/v1/responses";
        timezone = "Asia/Ho_Chi_Minh";
      };
      workingDirectory = "/var/lib/hermes/workspace";
      hermesHomeFiles."SOUL.md" = ./hermes/SOUL.md;
      documents."AGENTS.md" = ./hermes/AGENTS.md;
      mcpServers = {
        foundryvtt = {
          command = "/home/hermes/.bun/bin/bun";
          args = ["/home/hermes/mcp/foundryvtt-mcp/node_modules/foundryvtt-mcp/dist/index.js"];
          env = {
            FOUNDRY_URL = "http://localhost:30000";
            FOUNDRY_USERNAME = "clanker";
            FOUNDRY_PASSWORD = "\${FOUNDRY_PASSWORD}";
          };
        };
        actual-budget-mcp-usd = {
          command = "/usr/bin/npx";
          args = ["-y" "actual-budget-mcp"];
          env = {
            ACTUAL_SERVER_URL = "http://localhost:3000";
            ACTUAL_PASSWORD = "\${ACTUAL_PASSWORD}";
            ACTUAL_BUDGET_ID = "2250610e-de2a-4dd0-9c00-cc53702aafa4";
          };
        };
        actual-budget-mcp-rub = {
          command = "/usr/bin/npx";
          args = ["-y" "actual-budget-mcp"];
          env = {
            ACTUAL_SERVER_URL = "http://localhost:3000";
            ACTUAL_PASSWORD = "\${ACTUAL_PASSWORD}";
            ACTUAL_BUDGET_ID = "b9264161-5733-469f-86e7-21001c25c7d4";
          };
        };
        actual-budget-mcp-vnd = {
          command = "/usr/bin/npx";
          args = ["-y" "actual-budget-mcp"];
          env = {
            ACTUAL_SERVER_URL = "http://localhost:3000";
            ACTUAL_PASSWORD = "\${ACTUAL_PASSWORD}";
            ACTUAL_BUDGET_ID = "243173ea-33e3-4d68-88e6-5754f68a3aa0";
          };
        };
        actual-budget-mcp-myr = {
          command = "/usr/bin/npx";
          args = ["-y" "actual-budget-mcp"];
          env = {
            ACTUAL_SERVER_URL = "http://localhost:3000";
            ACTUAL_PASSWORD = "\${ACTUAL_PASSWORD}";
            ACTUAL_BUDGET_ID = "e5fe64a8-24d0-48ec-86c0-a18854650232";
          };
        };
      };
    };
  };
}

{ inputs, ... }:
{
  flake.modules.nixos.agents =
  {
    nixpkgs.overlays = [ inputs.llm-agents.overlays.shared-nixpkgs ];
    nix.settings = {
      extra-substituters = [ "https://cache.numtide.com" ];
      extra-trusted-public-keys = [
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };
  };
  flake.modules.homeManager.agents =
    { config, pkgs, ... }:
    {
      programs.opencode = {
        enable = true;
        package = pkgs.llm-agents.opencode;
      };
      programs.pi-coding-agent = {
        enable = true;
        configDir = "${config.xdg.configHome}/pi/agent";
        package = pkgs.llm-agents.pi;
      };
      home.shellAliases = {
        pia = ''pi -p --model "opencode-go/deepseek-v4-flash"'';
      };
      home.packages = with pkgs.llm-agents; [
        opencode2
      ];
    };
}

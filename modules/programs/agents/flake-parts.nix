{ inputs, ... }:
{
  flake-file.inputs = {
    llm-agents.url = "github:numtide/llm-agents.nix";
    hermes-agent.url = "github:NousResearch/hermes-agent";
  };
}

{
  flake.modules.homeManager.helium =
  { inputs, ... }:
  {
    imports = [
      inputs.helium-flake.homeModules.default
    ];
    programs.helium = {
      enable = true;
      policies = {
        "HomepageLocation" = "http://127.0.0.1:30000";
      };
    };
  };
}

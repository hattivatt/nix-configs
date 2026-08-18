{
  flake.modules.nixos.rebuild =
  { pkgs, ... }:
  {
    environment.systemPackages = with pkgs; [ local.rebuild ];
  };
}

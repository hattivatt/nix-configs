{
  flake.modules.nixos.shells =
  { pkgs, ... }:
  {
    environment.shells = with pkgs; [
      bash
      zsh
      nushell
    ];
    programs.zsh.enable = true;
  };
  flake.modules.homeManager.shells =
    { ... }:
    {
      imports = [
        ./_parts/nushell.nix
        ./_parts/zsh.nix
        ./_parts/starship.nix
        ./_parts/misc.nix
        ./_parts/fastfetch.nix
      ];
    };
}

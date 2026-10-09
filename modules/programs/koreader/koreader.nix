{
  flake.modules.homeManager.koreader =
  { pkgs, ... }:
  {
    home.packages = with pkgs; [ koreader ];
    xdg.dataFile."fonts/fast-font".source = "${pkgs.local.fast-font}/share/fonts";
  };
}

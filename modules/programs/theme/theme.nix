{
  flake.modules.homeManager.theme =
  { inputs, pkgs, ... }:
  {
    imports = [ inputs.catppuccin.homeModules.catppuccin ];
    catppuccin = {
      enable = true;
      cache.enable = true;
      autoEnable = true;
      flavor = "mocha";
      accent = "red";

      cursors = {
        enable = true;
        accent = "red";
      };
      kvantum = {
        enable = true;
        apply = true;
      };
    };
    home.packages = with pkgs; [
      catppuccin-gtk
    ];
    gtk = {
      enable = true;
      colorScheme = "dark";
      gtk3.theme.name = "catppuccin-mocha-red-standard+default";
      gtk4.theme.name = "catppuccin-mocha-red-standard+default";
    };
    qt = {
      enable = true;
      style.name = "kvantum";
    };
  };
}

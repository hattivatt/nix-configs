{
  flake.modules.homeManager.fbreader =
  { config, pkgs, lib, ... }:
  let
    defaultConfig = pkgs.writeText "FBReader.conf" ''
      [General]
      OpenFilesFolder=/home/hattivatt/Documents/Books
      SelectedFilesFolder=Book files (*.epub *.mobi *.fb2 *.fb2.zip *.lcpl)

      [options]
      controls\verticalMouseScrolling\mode=2
      css\useAlignment=true
      css\useFontFamily=false
      css\useFontSize=false
      css\useMargins=false
      litres%3Alitres.ru\sid=6w8yap153q5xdj2v0uao9w28617960cf
      permission\dataCollection=1
      text\fontFamily=Fast_Sans
      text\fontSize=30
      text\lineHeightPercent=120
      text\monospaceFontFamily=Fast_Mono
    '';
  in
  {
    home.packages = with pkgs.local; [ fbreader fast-font ];
    xdg.desktopEntries.fbreader = {
      name = "FBReader";
      comment = "Book reader";
      genericName = "Book reader";
      exec = "${pkgs.local.fbreader}/bin/fbreader";
      icon = "fbreader";
      type = "Application";
      startupNotify = true;
      categories = ["Education"];
    };
    home.activation.initAppConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      target="${config.xdg.configHome}/FBReader.ORG Limited/FBReader.conf"

      if [ ! -f "$target" ]; then
        mkdir -p "$(dirname "$target")"
        install -m 644 ${defaultConfig} "$target"
      fi
    '';
  };
}

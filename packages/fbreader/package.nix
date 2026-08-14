{ pkgs, ... }:
let
  fbreader = pkgs.appimageTools.wrapType2 {
    pname = "fbreader";
    version = "2.1.4";
    src = pkgs.fetchurl {
      url = "https://fbreader.org/static/packages/linux/FBReader_Book_Reader-x86_64-2.1.4.AppImage";
      hash = "sha256-3kpQRPVmoEtMWU/wQ8E3173ZnpUeQaRRLoFNkPaXhXE=";
    };
  };
in
pkgs.symlinkJoin {
  name = "fbreader";
  paths = [ fbreader ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    rm $out/bin/fbreader
    makeWrapper ${fbreader}/bin/fbreader $out/bin/fbreader \
      --set QT_QPA_PLATFORM xcb
  '';
}

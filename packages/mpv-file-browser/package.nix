{ pkgs }:
pkgs.stdenvNoCC.mkDerivation {
  pname = "mpv-script-file-browser";
  version = "v0.31";   # ветка mpv-v0.31, пинить по rev
  src = pkgs.fetchFromGitHub {
    owner = "CogentRedTester";
    repo = "mpv-file-browser";
    rev = "e07ab168fbba24063cd81c9b6f3fb8b85d5fe24d";
    sha256 = "zCDBxsGC7THQ2k0qDkjOq4TZm4thI2yk57a3i9PRCAs=";
  };
  installPhase = ''
    mkdir -p "$out/share/mpv/scripts/file-browser"
    cp -r main.lua modules addons LICENSE "$out/share/mpv/scripts/file-browser/"
  '';
}

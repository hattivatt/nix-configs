{ pkgs }:
pkgs.stdenvNoCC.mkDerivation {
  pname = "mpv-script-open-kinopoisk-page";
  version = "...";   # rev
  src = pkgs.fetchFromGitHub {
    owner = "WANDEX";
    repo = "mpv-open-kinopoisk-page";
    rev = "f34abe9ee345320bc77cd0945664383c7e8bbb51";
    sha256 = "v/cz71X7IVJFQq1IHf5JyQ9c1Vm8fpdBVaGtV4Vg+VU=";
  };
  installPhase = ''
    install -Dm644 open-kinopoisk-page.lua "$out/share/mpv/scripts/open-kinopoisk-page.lua"
    install -Dm644 open-kinopoisk-page.py "$out/share/mpv/scripts/open-kinopoisk-page.py"
  '';
}

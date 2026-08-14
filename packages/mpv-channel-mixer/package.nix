{ pkgs }:
pkgs.stdenvNoCC.mkDerivation {
  pname = "mpv-script-channel-mixer";
  version = "2019-06-12";
  src = pkgs.fetchgit {
    url = "https://gist.github.com/1e7ef04a151963b38e347a723d7e3201.git";
    rev = "67c7d93c7ae7ee55c38283b848b2c137ecaf08ea";
    sha256 = "yIHGxz/nQOGzB8VGYOTeEve0tjgrz9i3wHEgL6lFjVk=";   # nix-prefetch-git
  };
  installPhase = ''
    install -Dm644 "channel mixer.lua" "$out/share/mpv/scripts/channel_mixer.lua"
  '';
}

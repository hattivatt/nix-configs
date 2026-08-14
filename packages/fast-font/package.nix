{ pkgs, ... }:
pkgs.stdenvNoCC.mkDerivation {
  pname = "fast-font";
  version = "unstable-2026-06-18";

  src = pkgs.fetchFromGitHub {
    owner = "Born2Root";
    repo = "Fast-Font";
    rev = "aeae0775d9251365eae3b133cbf26ce0366f6108";
    hash = "sha256-DvC5F32qwNFMrxmPGWIYYsEdWI7pD5w6dt/cAz457+Y=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fonts/truetype
    cp fast-fonts/*.ttf $out/share/fonts/truetype/
    runHook postInstall
  '';

  meta = {
    description = "Fast Font for bionic reading";
  };
}

{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "teleport16";
  version = "16.5.18";  # поставь ту, которую требует сервер

  src = pkgs.fetchurl {
    url = "https://cdn.teleport.dev/teleport-v${version}-linux-amd64-bin.tar.gz";
    hash = "sha256-k2nMGcdUIXPFKo5esjeJIEWJAw1eUHIGqkm7dkmG0j8=";
  };

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = [
    pkgs.stdenv.cc.cc.lib
    pkgs.openssl
    pkgs.libfido2
  ];

  sourceRoot = "teleport";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp tsh tctl $out/bin/
    chmod +x $out/bin/*
    runHook postInstall
  '';

  meta.platforms = [ "x86_64-linux" ];
}

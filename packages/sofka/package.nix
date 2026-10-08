{ pkgs, ... }:
let
  version = "0.31.3";

  # Апстрим кладёт package.nix рядом с Cargo.toml и Cargo.lock, поэтому его
  # ссылки на . / (lib.cleanSource ./. и cargoLock.lockFile) резолвятся внутрь
  # src. Свой пакет не держим: правим только rev/hash при обновлении.
  src = pkgs.fetchFromGitHub {
    owner = "nklmilojevic";
    repo = "sofka";
    rev = "v${version}";
    hash = "sha256-ITcJ4OcEBPcsvOpC0I82h0X4Ewd3iv3wAr50RdYb+dU=";
  };
in
pkgs.callPackage (src + "/package.nix") { }

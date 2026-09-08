{ pkgs, ... }:
let
  version = "0.25.3";

  # Апстрим кладёт package.nix рядом с Cargo.toml и Cargo.lock, поэтому его
  # ссылки на . / (lib.cleanSource ./. и cargoLock.lockFile) резолвятся внутрь
  # src. Свой пакет не держим: правим только rev/hash при обновлении.
  src = pkgs.fetchFromGitHub {
    owner = "nklmilojevic";
    repo = "sofka";
    rev = "v${version}";
    hash = "sha256-e/+cdD8B+yE4tQzk73LdUbAX9ULKn4XJyoBUYb3fVOs=";
  };
in
pkgs.callPackage (src + "/package.nix") { }

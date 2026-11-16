{ pkgs, ... }:
let
  version = "0.37.0";

  # Апстрим кладёт package.nix рядом с Cargo.toml и Cargo.lock, поэтому его
  # ссылки на . / (lib.cleanSource ./. и Cargo.lock) резолвятся внутрь src.
  # Свой пакет не держим: правим только rev/hash при обновлении.
  src = pkgs.fetchFromGitHub {
    owner = "nklmilojevic";
    repo = "sofka";
    rev = "v${version}";
    hash = "sha256-5n9/eZsZa7EIwm8bZvG3cAmXusgLmvPQREEcWSqrIts=";
  };

  # С 0.32 апстрим собирает через crane и ждёт craneLib отдельным аргументом,
  # которого нет в nixpkgs, так что приносим библиотеку сами.
  craneLib = import (pkgs.fetchFromGitHub {
    owner = "ipetkov";
    repo = "crane";
    rev = "v0.24.0";
    hash = "sha256-lWhBbBvC05/xwivKBBiM2YNizpmgqCgyOIzomvRuwxs=";
  } + "/default.nix") { inherit pkgs; };
in
pkgs.callPackage (src + "/package.nix") { inherit craneLib; }

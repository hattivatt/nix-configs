# KoInsight — self-hosted KOReader reading-statistics server.
#
# Standalone buildNpmPackage, usable via plain `pkgs.callPackage`, e.g.:
#
#   pkgs.callPackage ./nixos-module/package.nix { }
#
# or, in the user's dendritic config, dropped into `packages/koinsight/package.nix`
# so the pkgs-by-name overlay exposes it as `pkgs.local.koinsight` (which is the
# default of `services.koinsight.package`).
#
# The build recipe mirrors the project's own flake.nix (which builds successfully
# upstream) but is pinned against a GitHub release tag instead of a local path,
# matching the user's `calibre-web-automated` package style.
{ lib
, stdenv
, fetchFromGitHub
, fetchNpmDeps
, buildNpmPackage
, nodejs_22
, makeWrapper
,
}:

buildNpmPackage (finalAttrs: {
  pname = "koinsight";
  version = "0.2.5";

  # Pinned upstream (user's fork) release tag. To upgrade: bump `rev`/`version`
  # and re-iterate `hash` + `npmDeps.hash` (see README).
  src = fetchFromGitHub {
    owner = "hattivatt";
    repo = "KoInsight";
    rev = "v0.2.5";
    hash = "sha256-lJMkyUVeuEH5aXtpgxt/h/KywGk5BlYqpDyA9lUit0k=";
    # The repo has no .gitmodules; plugins/ are plain directories.
    fetchSubmodules = false;
  };

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-ZyUcwHBkCi686IPx6jw25HMlVErI2xjRYancZ4ISzTo=";
  };

  # Node 22 is required by the project (`engines.node >= 22`).
  nodejs = nodejs_22;

  env = {
    # Force better-sqlite3 to compile from source with node-gyp instead of
    # trying (and failing) to download a prebuilt binary offline.
    npm_config_build_from_source = "true";
    npm_config_update_notifier = "false";
    npm_config_fund = "false";
    npm_config_audit = "false";
    TURBO_TELEMETRY_DISABLED = "1";
  };

  # Skip the root `turbo run build` script: Turbo wants to talk to its remote
  # cache / write to $HOME. Build the workspaces directly in dependency order.
  dontNpmBuild = true;
  buildPhase = ''
    runHook preBuild
    npm run --workspace=@koinsight/common build
    npm run --workspace=server build
    npm run --workspace=web build
    runHook postBuild
  '';

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    root="$out/libexec/koinsight"
    mkdir -p "$root"

    # Runtime node_modules (includes the compiled better-sqlite3 addon).
    cp -r node_modules "$root/node_modules"
    cp package.json "$root/package.json"

    # Compiled server + static web build + KOReader plugin bundle.
    mkdir -p "$root/apps/server" "$root/apps/web"
    cp -r apps/server/dist "$root/apps/server/dist"
    cp -r apps/web/dist "$root/apps/web/dist"
    cp -r plugins "$root/plugins"

    # `@koinsight/common` is a workspace symlink; after the monorepo layout is
    # flattened the runtime `require('@koinsight/common/...')` cannot rely on
    # workspace resolution, so ship a self-contained copy with an explicit
    # exports map (Node 22 supports require() of the ES modules it points at).
    rm -f "$root/node_modules/@koinsight/common"
    mkdir -p "$root/node_modules/@koinsight/common"
    cp -r packages/common/dist "$root/node_modules/@koinsight/common/dist"

    # Take the version from the real workspace package.json so the synthetic
    # copy never drifts from the released version.
    common_version="$(node -p "require('./packages/common/package.json').version")"

    cat > "$root/node_modules/@koinsight/common/package.json" <<EOF
    {
      "name": "@koinsight/common",
      "version": "''${common_version}",
      "type": "module",
      "exports": {
        "./types": "./dist/types/index.js",
        "./types/*": "./dist/types/*.js",
        "./utils/*": "./dist/utils/*.js",
        "./*": "./dist/*.js"
      }
    }
    EOF

    # Launcher: DATA_PATH must be writable (the in-store default would resolve
    # into the read-only Nix store). The NixOS module always sets DATA_PATH,
    # PORT, HOSTNAME and NODE_ENV explicitly; these defaults are for ad-hoc runs.
    mkdir -p "$out/bin"
    makeWrapper ${nodejs_22}/bin/node "$out/bin/koinsight" \
      --prefix PATH : ${lib.makeBinPath [ nodejs_22 ]} \
      --set-default NODE_ENV production \
      --run 'if [ -z "''${DATA_PATH-}" ]; then export DATA_PATH="''${XDG_DATA_HOME:-$HOME/.local/share}/koinsight"; fi' \
      --add-flags "$out/libexec/koinsight/apps/server/dist/app.js"

    runHook postInstall
  '';

  doInstallCheck = false;

  meta = {
    description = "Self-hosted KOReader reading statistics server";
    longDescription = ''
      KoInsight collects and visualises KOReader reading statistics: an Express
      server backed by SQLite (better-sqlite3) that also serves a React SPA and
      the KOReader plugin bundle.
    '';
    homepage = "https://github.com/hattivatt/KoInsight";
    changelog = "https://github.com/hattivatt/KoInsight/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "koinsight";
    platforms = lib.platforms.linux;
  };
})

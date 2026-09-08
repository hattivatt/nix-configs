# Autolith binary release (path B: official per-release tarball), run inside an
# FHS user-space environment.
#
# The version below tracks upstream tags exactly. We consume the glibc build
# (x86_64-linux), not the musl one: the launcher validates that the RELEASE
# platform matches the host libc, and on NixOS /bin/sh is glibc.
#
# The bundled SBCL runtime is dynamically linked, so autoPatchelfHook points
# its ELF interpreter and libraries at nixpkgs glibc; without that the runtime
# hits NixOS's stub-ld when building the per-machine images.
#
# The release tree mirrors the official installer layout (releases/<tag>/, plus
# current and bin/autolith links) so the launcher's "selected release" and
# self-update checks resolve correctly. Self-update is disabled via env because
# the store is read-only; bump this package to upgrade.
#
# WHY AN FHS ENV:
# cl-exec-sandbox discovers its backend by probing a fixed set of absolute
# paths: linux--find-bwrap only checks /usr/bin/bwrap and /bin/bwrap, and
# path--executable-file-p requires /usr/bin/test or /bin/test. None of those
# exist on NixOS, where every binary lives in the store. So even though bwrap
# and the cl-exec-sandbox-helper binary are present and CL_EXEC_SANDBOX_BWRAP /
# CL_EXEC_SANDBOX_HELPER are exported, the probe returns nil and Autolith starts
# with the workspace command sandbox reported unavailable.
#
# Running the launcher inside buildFHSEnv gives it /usr/bin and /bin populated
# from targetPkgs (coreutils provides test, bubblewrap provides bwrap, git and
# openssl for the rest of the runtime), which makes those fixed probes pass and
# re-enables real filesystem/network isolation for command approvals. Autolith's
# own nested bwrap calls work because buildFHSEnv bind-mounts the host root.
{
  pkgs,
  lib,
}:
let
  version = "0.49.0";
  platform = "x86_64-linux";
  release = "v${version}";
  releaseName = "${release}-${platform}";

  # The upstream tarball, laid out like the official installer and auto-patched
  # for the NixOS glibc runtime.
  releaseTree = pkgs.stdenv.mkDerivation {
    pname = "autolith-release";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/lambda-symbolics/autolith/releases/download/${release}/autolith-${release}-${platform}.tar.gz";
      hash = "sha256-TTWpYOKupJk/phgFbUcBNuj5v7XXPfecJ57AVZNtQsI=";
    };

    sourceRoot = "autolith-${release}-${platform}";

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.makeWrapper
    ];

    buildInputs = [
      pkgs.glibc
      pkgs.zlib
      pkgs.zstd
      pkgs.openssl
      pkgs.libgcc
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/releases/${releaseName}" "$out/bin"
      cp -r . "$out/releases/${releaseName}/"
      ln -s "releases/${releaseName}" "$out/current"
      ln -s ../current/bin/autolith "$out/bin/autolith"
      runHook postInstall
    '';

    postFixup = ''
      wrapProgram "$out/releases/${releaseName}/bin/autolith" \
        --set AUTOLITH_NO_UPDATE_CHECK 1 \
        --set AUTOLITH_SUPPRESS_UPDATE_OFFER 1
    '';
  };

  # Sets the cl-exec-sandbox discovery env vars, then execs the launcher.
  # Runs inside the FHS env, where /usr/bin/bwrap and /usr/bin/test exist.
  runScript = pkgs.writeShellScript "autolith-run" ''
    export CL_EXEC_SANDBOX_BWRAP=/usr/bin/bwrap
    export CL_EXEC_SANDBOX_HELPER='${releaseTree}/releases/${releaseName}/libexec/cl-exec-sandbox-helper'
    exec '${releaseTree}/bin/autolith' "$@"
  '';
in
pkgs.buildFHSEnv {
  pname = "autolith";
  inherit version;

  targetPkgs = ps: with ps; [
    coreutils
    git
    bubblewrap
    openssl
  ];

  runScript = "${runScript}";

  meta = {
    description = "Live, self-modifying Common Lisp AI agent (binary release, FHS)";
    homepage = "https://github.com/lambda-symbolics/autolith";
    changelog = "https://github.com/lambda-symbolics/autolith/releases/tag/${release}";
    license = lib.licenses.isc;
    platforms = lib.platforms.linux;
    mainProgram = "autolith";
  };
}

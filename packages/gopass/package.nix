{ pkgs, ... }:
let
  gopass = pkgs.gopass.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./gopass-libsecret-dh.patch ];
  });
in
pkgs.symlinkJoin {
  name = "gopass";
  paths = [ gopass ];
  nativeBuildInputs = [ pkgs.makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/gopass \
      --unset PASSWORD_STORE_DIR
  '';
}

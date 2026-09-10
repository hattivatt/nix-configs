{ pkgs, lib }:
pkgs.writers.writePython3Bin "autoskip" {
  libraries = with pkgs.python3Packages; [
    dbus-python
    pygobject3
  ] ++ lib.optional (lib.versionOlder pkgs.python3.version "3.11") tomli;
  makeWrapperArgs = [
    "--prefix"
    "GI_TYPELIB_PATH"
    ":"
    (lib.makeSearchPathOutput "lib" "girepository-1.0" [
      pkgs.glib
      pkgs.gobject-introspection
    ])
  ];
} (builtins.readFile ./autoskip.py)

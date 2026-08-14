{ pkgs, lib }:
pkgs.writers.writePython3Bin "autoskip" {
  libraries = with pkgs.python3Packages; [
    dbus-python
    pygobject3
  ];
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

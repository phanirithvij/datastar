{
  pkgs ? import <nixpkgs> { },
}:
with pkgs;
let
  bin = v: lib.meta.getExe v;
  navi-shell-hook-local = stdenv.mkDerivation {
    name = "navi-shell-hook-local";
    dontUnpack = true;
    buildPhase = ''
      ${bin navi} widget bash \
        | sed 's/_navi_widget/_navi_widget_currdir/g' \
        | sed 's/--print/--print --path "docs"/g' \
        | sed 's/C-g/C-j/g' \
      > $out
      chmod +x $out
      patchShebangs $out
    '';
  };
  navi-shell-hook-global = stdenv.mkDerivation {
    name = "navi-shell-hook-global";
    dontUnpack = true;
    buildPhase = ''
      ${bin navi} widget bash > $out
      chmod +x $out
      patchShebangs $out
    '';
  };
in
''
  unset _navi_call
  unset _navi_widget_currdir _navi_widget_currdir_legacy
  unset _navi_widget _navi_widget_legacy
  source ${navi-shell-hook-local}
  source ${navi-shell-hook-global}
''

{ menu, pkgs }:
with pkgs;
let
  inherit (pkgs) lib;
  bin = p: lib.meta.getExe p;
  task = "${pkgs.go-task}/bin/task";
  navi_fallback = pkgs.writeShellScript "navi_custom_find" ''
    v=$(${bin navi} -q $1 -p docs --best-match --print)
    if [ -n "$v" ]; then echo $v; $v; else echo $1; $1; fi
  '';
in
''
  % task

  # list
  ${task} -a

  # watch
  ${task} -w hot

  # select
  ${task} <tasks>
  $ tasks: ${task} -j -a | ${bin jq} -r '.tasks.[].name'

  % nix

  # menu, help
  ${navi_fallback} <menu>
  $ menu: ${bin menu}

  # statix (git-hooks)
  ${bin statix} check

  # deadnix (git-hooks)
  ${bin deadnix} .

  # nixfmt (git-hooks)
  ${bin nixfmt-rfc-style} .

  # npins
  ${bin npins} --directory nix/npins show
''

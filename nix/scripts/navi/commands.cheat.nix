{ menu, pkgs }:
with pkgs;
let
  inherit (pkgs) lib;
  bin = p: lib.meta.getExe p;
  task = "${pkgs.go-task}/bin/task";
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
  <menu>
  $ menu: ${bin menu}

  # statix
  ${bin statix} check

  # deadnix
  ${bin deadnix} .

  # nixfmt
  ${bin nixfmt-rfc-style} **/*.nix

  # npins
  ${bin npins} --directory nix/npins show
''

let
  sources = import ./nix/npins;
  pkgs = import sources.nixpkgs { };
  inherit (pkgs) lib;
  stripStorePrefix = import ./nix/lib/strip-store-prefix.nix lib;
  scripts = import ./nix/scripts { inherit pkgs stripStorePrefix menu; };
  inherit (scripts) script_names;
  nix_tools = with pkgs; [
    nixfmt-rfc-style
    npins
    nix-output-monitor
    deadnix
    statix
  ];
  script_names' = builtins.concatStringsSep " " (
    builtins.map stripStorePrefix (lib.map lib.meta.getExe nix_tools) ++ script_names
  );
  menu = pkgs.writeScriptBin "menu" ''
    echo ${script_names'} | tr ' ' '\n'
  '';
in
pkgs.mkShellNoCC {
  env = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = true;
  };

  shellHook = ''
    git lfs install --local
    git lfs fetch
    git lfs checkout

    task -a
    ${menu}/bin/menu
    echo try ctrl+j

    mkdir -p ./docs
    source ${scripts.navi_shell_hook}
    ln -sf ${scripts.navi_cheat} docs/commands.gen.cheat
  '';

  packages =
    with pkgs;
    [
      git-lfs
      go
      go-task
      jq
      templ

      killall
      pnpm
      nodejs-slim_20

      navi
      fzf
    ]
    ++ nix_tools
    ++ scripts.custom_scripts
    ++ [ menu ];
}

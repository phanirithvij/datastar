{
  pkgs,
  stripStorePrefix,
  menu,
}:
let
  toplevel = "$(git rev-parse --show-toplevel)";
  run-site-bin-nix = pkgs.writeScriptBin "run-site-bin-nix" ''
    $(nix-build ${toplevel})/bin/site_bin
  '';
  build-site-bin-nix = pkgs.writeScriptBin "build-site-bin-nix" ''
    if [ -n "$CI" ]; then
      nix-build ${toplevel}
    else
      nix-build ${toplevel} --log-format internal-json 2>&1| nom --json
    fi
  '';
  playwright-run-ui = pkgs.writeScriptBin "playwright-run-ui" ''
    cd ${toplevel}/packages/playwright
    pnpm i
    pnpm playwright test --ui
  '';
  playwright-run-ci = pkgs.writeScriptBin "playwright-run-ci" ''
    cd ${toplevel}/packages/playwright
    pnpm i
    pnpm playwright test 2>/dev/null
  '';
  custom_scripts = [
    build-site-bin-nix
    run-site-bin-nix
    playwright-run-ui
    playwright-run-ci
  ];
  script_names = builtins.map stripStorePrefix custom_scripts;
  navi_shell_hook = import ./navi/shell-hook.nix { inherit pkgs; };
  navi_cheat = pkgs.writeTextFile {
    name = "commands.cheat";
    text = (import ./navi/commands.cheat.nix { inherit pkgs menu; });
  };
in
{
  inherit custom_scripts script_names navi_shell_hook;
  inherit navi_cheat;
}

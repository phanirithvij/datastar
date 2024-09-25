let
  pkgs = import <nixpkgs> { };
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
  '';
  packages = with pkgs; [
    git-lfs
    go
    go-task
    templ

    killall
    pnpm
    nodejs-slim_20
  ];
}

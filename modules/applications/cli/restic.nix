_: {
  flake.modules.homeManager.home-kit-features-cli-restic = { pkgs, ... }: {
    home.packages = [ pkgs.restic ];
  };
}

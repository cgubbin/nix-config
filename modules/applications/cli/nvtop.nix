_: {
  flake.modules.homeManager."home-kit-features-cli-nvtop" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib) mkIf;
      cfg = config.home-config.cli;
    in
    {
      home.packages = mkIf (cfg.nvTop.enable && pkgs.stdenv.hostPlatform.isLinux) (
        with pkgs;
        [
          nvtopPackages.nvidia
        ]
      );
    };
}

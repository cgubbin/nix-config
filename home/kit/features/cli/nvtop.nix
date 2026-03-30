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
  home.packages = mkIf (cfg.nvTop.enable && pkgs.stdenv.isLinux) (
    with pkgs;
    [
      nvtopPackages.nvidia
    ]
  );
}

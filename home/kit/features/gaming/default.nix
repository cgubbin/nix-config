{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.home-config;
in
{
  programs.steam = mkIf (cfg.gaming.enable && pkgs.stdenv.isLinux) {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
}

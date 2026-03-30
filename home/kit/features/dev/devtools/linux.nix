{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.home-config.dev;
in
{
  services.ollama = mkIf cfg.devTools.enable {
    enable = true;
    # acceleration = "cuda";
    package = pkgs.ollama-cpu;
  };
}

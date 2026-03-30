{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.home-config.gui;
in
{
  imports = [ ./aerospace.nix ];
  home.packages = mkIf cfg.utils.enable (
    with pkgs;
    [
      caffeine
      karabiner-elements
    ]
  );
}

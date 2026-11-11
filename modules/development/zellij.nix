{ config, ... }:
let
  top = config;
in
{
  flake.modules.homeManager."home-kit-features-dev-zellij" =
    { config, lib, ... }:
    let
      cfg = config.home-config.dev;
    in
    {
      imports = [ top.flake.modules.homeManager.shared-zellij ];

      # Keep the shared module's public default enabled for consumers, while
      # preserving Kitsune's existing opt-in gate at this internal boundary.
      programs.zellij.enable = lib.mkIf (!cfg.devTools.enable) (lib.mkForce false);
    };
}

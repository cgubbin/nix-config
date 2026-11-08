{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager.home-kit-features = {
    imports = [
      hm.home-kit-features-cli
      hm.home-kit-features-desktop
      hm.home-kit-features-dev
      hm.home-kit-features-fonts
      hm.home-kit-features-gui
    ];
  };
}

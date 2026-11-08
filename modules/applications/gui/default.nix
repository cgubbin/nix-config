{ config, ... }:
let
  top = config;
in
{
  flake.modules.homeManager."home-kit-features-gui" = { ... }: {
    imports = [
      top.flake.modules.homeManager."home-kit-features-gui-common"

      top.flake.modules.homeManager."home-kit-features-gui-firefox"
      top.flake.modules.homeManager."home-kit-features-gui-kitty"
      top.flake.modules.homeManager."home-kit-features-gui-linux"
    ];
  };
}

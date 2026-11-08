{ config, ... }:
let
  top = config;
in
{
  flake.modules.homeManager."home-kit-features-desktop" =
    { ... }:
    {
      imports = [
        top.flake.modules.homeManager."home-kit-features-desktop-linux"

      ];
    };
}

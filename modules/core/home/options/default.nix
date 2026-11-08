{ config, ... }:
let
  top = config;
in
{
  flake.modules.homeManager."home-kit-global-options" =
    {
      ...
    }:
    {
      imports = [
        top.flake.modules.homeManager."home-kit-global-options-fonts"
        top.flake.modules.homeManager."home-kit-global-options-monitors"
        top.flake.modules.homeManager."home-kit-global-options-features"
      ];
    };
}

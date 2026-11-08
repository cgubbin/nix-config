{ config, ... }:
let
  top = config;
in
{
  flake.modules.homeManager."home-kit-features-dev" =
    { ... }:
    {
      imports = [
        top.flake.modules.homeManager."home-kit-features-dev-devtools"
        top.flake.modules.homeManager."home-kit-features-dev-zellij"
      ];
    };
}

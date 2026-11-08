{ config, ... }:
let
  top = config;
in
{
  flake.modules.homeManager."home-kit-global" =
    { ... }:
    {
      imports = [
        top.flake.modules.homeManager."home-kit-global-options"
        top.flake.modules.homeManager."home-kit-global-tools"
        top.flake.modules.homeManager."home-kit-global-home-manager"
        top.flake.modules.homeManager."home-kit-global-home-manager-linux"

        #./../../../home/kit/global/sops.nix
      ];
    };
}

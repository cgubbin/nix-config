{ config, ... }:
let
  top = config;
in
{
  flake.modules.homeManager."home-kit-features-cli" = { ... }: {
    imports = [
      top.flake.modules.homeManager.shared-cli
      top.flake.modules.homeManager."home-kit-features-cli-nvtop"
      top.flake.modules.homeManager."home-kit-features-cli-restic"
      top.flake.modules.homeManager."home-kit-features-cli-syncthing"
    ];
  };
}

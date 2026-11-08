{ config, ... }:
let
  top = config;
in
{
  flake.modules.homeManager."home-kit-features-dev-devtools" = { ... }: {
    imports = [
      top.flake.modules.homeManager."home-kit-features-dev-devtools-common"

      top.flake.modules.homeManager."home-kit-features-dev-devtools-llm"
      # top.flake.modules.homeManager."home-kit-features-dev-devtools-linux"
    ];
  };
}

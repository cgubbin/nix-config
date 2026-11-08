{ config, ... }:
let
  top = config;
in
{
  flake.modules.homeManager."home-kit-global-tools-nixvim-module" = { ... }: {
    imports = [
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-keymappings"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-options"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-themes"
    ];
  };
}

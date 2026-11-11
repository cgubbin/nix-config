{ config, ... }:
let
  top = config;
in
{
  flake.modules.homeManager."home-kit-global-tools" = { config, ... }: {
    imports = [
      top.flake.modules.homeManager.shared-shells
      top.flake.modules.homeManager."home-kit-global-tools-emacs"
      top.flake.modules.homeManager."home-kit-global-tools-git"
      top.flake.modules.homeManager.shared-editor
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-obsidian"
      top.flake.modules.homeManager."home-kit-global-tools-obsidian"
    ];
    sharedEditor.configDirectory = "${config.home.homeDirectory}/nix-config";
  };
}

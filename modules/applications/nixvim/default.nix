{ config, ... }:
let
  top = config;
in
{
  flake.modules.homeManager."home-kit-global-tools-nixvim" =
    {
      lib,
      ...
    }:
    {
      imports = [
        top.flake.modules.homeManager."home-kit-global-tools-nixvim-completion"
        top.flake.modules.homeManager."home-kit-global-tools-nixvim-keymappings"
        top.flake.modules.homeManager."home-kit-global-tools-nixvim-options"
        top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins"
        top.flake.modules.homeManager."home-kit-global-tools-nixvim-themes"
      ];

      programs.nixvim = {
        enable = true;
        defaultEditor = lib.mkDefault true;
        extraConfigLuaPre = lib.mkBefore ''
          require("kit.project").setup()
        '';
        vimdiffAlias = true;
        impureRtp = true;
        withPython3 = true;

        nixpkgs.useGlobalPackages = true;
      };
    };
}

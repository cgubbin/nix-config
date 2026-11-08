{ config, ... }:
let
  top = config;
in
{
  flake.modules.nixos."hosts-common-global" =
    { ... }:
    {
      imports = [
        top.flake.modules.nixos."hosts-common-global-locale"
        top.flake.modules.nixos."hosts-common-global-nix"
      ];

      nixpkgs = {
        overlays = [ ];
        config = {
          allowUnfree = true;
        };
      };

      system.stateVersion = "25.05";
    };
}

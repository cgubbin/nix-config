{ inputs, ... }: {
  flake.modules.nixos."hosts-common-global-nix" =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      nix = {
        registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

        nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
            "ca-derivations"
          ];
          auto-optimise-store = true;

          trusted-users = [ "kit" ];

          # NixOS supplies cache.nixos.org and its key by default.
          substituters = [ "https://nix-community.cachix.org" ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };
      };

      programs.nh = {
        enable = true;
        clean.enable = false;
        flake = "/home/kit/nix-config";
      };

      hardware.keyboard.zsa.enable = true;

      environment.systemPackages = [
        pkgs.nix-direnv
      ];
    };
}

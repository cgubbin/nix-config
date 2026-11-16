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
          # numtide: daily CI builds of llm-agents (codex, claude-code, …);
          # without it those compile from source on every update. Keys are the
          # ones the inputs publish in their own flake nixConfig.
          substituters = [
            "https://nix-community.cachix.org"
            "https://cache.numtide.com"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
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

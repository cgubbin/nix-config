{ inputs, config, ... }:
let
  system = "x86_64-linux";
  master = _final: _prev: {
    master = import inputs.nixpkgs-master {
      inherit system;
      config.allowUnfree = true;
    };
  };
  unstable = _final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  };
  firmware = _final: _prev: {
    sofFirmwareUnstable = (import inputs.nixpkgs-unstable { inherit system; }).sof-firmware;
  };
in
{
  flake.nixosConfigurations.kitsune = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      config.flake.modules.nixos.kitsune-sync
      config.flake.modules.nixos.hosts-kitsune
      inputs.home-manager.nixosModules.home-manager
      inputs.stylix.nixosModules.stylix
      inputs.nix-index-database.nixosModules.nix-index
      {
        nixpkgs.overlays = [
          master
          unstable
          firmware
        ];
        home-manager = {
          users.kit = config.flake.modules.homeManager.home-kit-kitsune;
          backupFileExtension = "backup_hm";
          sharedModules = [
            inputs.nixvim.homeModules.nixvim
            inputs.sops-nix.homeManagerModules.sops
            { nixpkgs.overlays = [ master ]; }
          ];
        };
        programs.nix-index-database.comma.enable = true;
        programs.nix-index.enable = true;
        boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
      }
    ];
  };
}

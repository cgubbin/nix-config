{ config, ... }:
let
  modules = config.flake.modules;
in
{
  flake.modules.nixos.kitsune-sync = { config, lib, ... }: {
    imports = [ modules.nixos.media-sync-guard ];
    home-manager.users.kit.services.syncthing.enable = lib.mkForce false;
    services.syncthing = {
      enable = true;
      user = "kit";
      group = "users";
      dataDir = "/home/kit";
      configDir = "/home/kit/.local/state/syncthing";
      databaseDir = "/home/kit/.local/state/syncthing";
      guiAddress = "127.0.0.1:8385";
      overrideDevices = true;
      overrideFolders = true;
      settings = config.home-manager.users.kit.services.syncthing.settings;
      mediaGuard = {
        enable = true;
        source = "/dev/disk/by-uuid/955df379-9988-4bf1-8b25-faa9cc0f4aa0";
      };
    };
  };
}

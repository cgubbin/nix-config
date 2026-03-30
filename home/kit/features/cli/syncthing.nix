{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    mapAttrs
    mapAttrs'
    nameValuePair
    ;

  cfg = config.home-config.cli.syncthing;
  homeDir = config.home.homeDirectory;
in
{
  services.syncthing = mkIf cfg.enable {
    enable = true;

    guiAddress = "127.0.0.1:8385";

    key = "${homeDir}/.${cfg.localKeyDirName}/key.pem";
    cert = "${homeDir}/.${cfg.localKeyDirName}/cert.pem";

    overrideDevices = true;
    overrideFolders = true;

    settings = {
      devices = mapAttrs (_name: id: { inherit id; }) cfg.devices;

      folders = mapAttrs (_folderName: folderCfg: {
        label = folderCfg.label or _folderName;
        path = "${homeDir}/${folderCfg.path}";
        devices = folderCfg.devices;

        versioning =
          folderCfg.versioning or {
            type = "simple";
            params = {
              keep = "10";
              cleanoutDays = "0";
            };
          };
      }) cfg.folders;
    };
  };
}

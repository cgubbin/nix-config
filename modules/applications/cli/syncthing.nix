_: {
  flake.modules.homeManager."home-kit-features-cli-syncthing" =
    {
      config,
      lib,
      ...
    }:
    let
      inherit (lib)
        mkIf
        mapAttrs
        ;

      cfg = config.home-config.cli.syncthing;
      homeDir = config.home.homeDirectory;
    in
    {
      services.syncthing = mkIf cfg.enable {
        enable = true;

        guiAddress = "127.0.0.1:8385";

        key = if cfg.useIdentityFiles then "${homeDir}/.${cfg.localKeyDirName}/key.pem" else null;
        cert = if cfg.useIdentityFiles then "${homeDir}/.${cfg.localKeyDirName}/cert.pem" else null;

        overrideDevices = true;
        overrideFolders = true;

        settings = {
          devices = mapAttrs (_name: id: { inherit id; }) cfg.devices;

          folders = mapAttrs (_folderName: folderCfg: {
            label = if folderCfg.label == null then _folderName else folderCfg.label;
            path = if lib.hasPrefix "/" folderCfg.path then folderCfg.path else "${homeDir}/${folderCfg.path}";
            inherit (folderCfg) type;
            inherit (folderCfg) devices;

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
    };
}

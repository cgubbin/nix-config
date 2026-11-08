_: {
  flake.modules.nixos.media-sync-guard =
    {
      config,
      lib,
      pkgs,
      utils,
      ...
    }:
    let
      cfg = config.services.syncthing.mediaGuard;
      mountUnit = "${utils.escapeSystemdPath cfg.path}.mount";
      verify = pkgs.writeShellScript "verify-sync-source" ''
        set -eu
        actual=$(${pkgs.util-linux}/bin/findmnt -rn -M ${lib.escapeShellArg cfg.path} -o SOURCE)
        expected=${lib.escapeShellArg cfg.source}
        case "$expected" in
          /*) expected=$(${pkgs.coreutils}/bin/readlink -f "$expected");;
        esac
        if [ "$actual" != "$expected" ]; then
          echo "Refusing synchronization: unexpected source at ${cfg.path}" >&2
          exit 1
        fi
      '';
    in
    {
      options.services.syncthing.mediaGuard = {
        enable = lib.mkEnableOption "mount identity and lifecycle guard for synchronized media";
        path = lib.mkOption {
          type = lib.types.str;
          default = "/mnt/Media";
        };
        source = lib.mkOption { type = lib.types.str; };
      };
      config = lib.mkIf cfg.enable {
        systemd.services.syncthing = {
          requires = [ mountUnit ];
          bindsTo = [ mountUnit ];
          after = [ mountUnit ];
          unitConfig.RequiresMountsFor = cfg.path;
          serviceConfig = {
            ExecStartPre = [ "${verify}" ];
            # Resolve the expected block-device symlink inside the service.
            PrivateDevices = lib.mkForce false;
          };
        };
      };
    };
}

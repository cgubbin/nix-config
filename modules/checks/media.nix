{ config, ... }: {
  perSystem = { pkgs, ... }: {
    checks.media-mount-lifecycle = pkgs.testers.runNixOSTest {
      name = "media-mount-lifecycle";
      nodes.machine = { pkgs, ... }: {
        imports = [ config.flake.modules.nixos.media-sync-guard ];
        services.syncthing.mediaGuard = {
          enable = true;
          source = "media-test";
        };
        systemd.mounts = [
          {
            what = "media-test";
            where = "/mnt/Media";
            type = "tmpfs";
            unitConfig.ConditionPathExists = "/run/media-available";
          }
        ];
        systemd.services.syncthing.serviceConfig = {
          ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
          Type = "simple";
        };
      };
      testScript = ''
        start_all()
        machine.wait_for_unit("multi-user.target")
        machine.fail("systemctl start syncthing.service")
        machine.fail("systemctl is-active --quiet syncthing.service")
        machine.succeed("touch /run/media-available; systemctl reset-failed; systemctl start syncthing.service")
        machine.wait_for_unit("syncthing.service")
        machine.succeed("systemctl stop mnt-Media.mount")
        machine.wait_until_fails("systemctl is-active --quiet syncthing.service")
        machine.succeed("mount -t tmpfs wrong-source /mnt/Media")
        machine.fail("systemctl start syncthing.service")
        machine.succeed("umount /mnt/Media; systemctl reset-failed; systemctl start syncthing.service")
        machine.wait_for_unit("syncthing.service")
      '';
    };
  };
}

{ config, ... }:
let
  c = config.flake.nixosConfigurations.kitsune.config;
  h = c.home-manager.users.kit;
in
{
  # Discovery registers this definition but Kitsune never selects it.
  flake.modules.nixos.unselected-probe = {
    environment.variables.DENDRITIC_UNSELECTED_PROBE = "unexpected";
  };
  perSystem = { pkgs, ... }: {
    checks.kitsune-config =
      assert !(c.environment.variables ? DENDRITIC_UNSELECTED_PROBE);
      assert c.system.stateVersion == "25.05";
      assert h.home.stateVersion == "26.05";
      assert !h.services.syncthing.enable;
      assert c.services.syncthing.user == "kit";
      assert c.services.syncthing.configDir == "/home/kit/.local/state/syncthing";
      assert builtins.elem "mnt-Media.mount" c.systemd.services.syncthing.bindsTo;
      assert c.security.pam.services ? hyprlock;
      assert !(h.services.mako.enable or false);
      assert builtins.elem "graphical-session.target" h.systemd.user.services.swaync.Install.WantedBy;
      pkgs.runCommand "kitsune-config" { nativeBuildInputs = [ pkgs.git ]; } ''
        test "$(git config --file ${
          h.xdg.configFile."git/config".source
        } --get user.email)" = chris.gubbin@gmail.com
        grep -q 'after_sleep_cmd = .*hyprctl dispatch dpms on' ${
          h.home.file.".config/hypr/hypridle.conf".source
        }
        if grep -q 'exec-once = .*swaync' ${h.xdg.configFile."hypr/hyprland.conf".source}; then exit 1; fi
        touch "$out"
      '';
  };
}

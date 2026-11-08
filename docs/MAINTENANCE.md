# Maintaining Kitsune

Kitsune is the sole machine output. The work host lives in its own repository;
MacBook support has been retired. Every Nix file under `modules/` is a top-level
flake-parts module. Discovery registers named NixOS/Home Manager definitions;
only selected definitions affect a host. `modules/hosts/kitsune.nix` constructs
Kitsune. `modules/hosts/kitsune/home.nix` selects its home profile.

## Feature ownership

- `modules/core/`: Nix, locale, account and typed home parameters.
- `modules/desktop/`: Hyprland, lock/idle, notifications and monitors' consumers.
- `modules/applications/`: shared shells, CLI, editor, GUI, fonts and home tools.
- `modules/development/`: selected developer, cloud and AI tools.
- `modules/services/`: system Syncthing and its mount guard.
- `modules/shared/`: supported consumer-facing exports.
- `modules/checks/`: generated-configuration and isolated lifecycle checks.

Internal names retain their source provenance to make this migration reviewable;
use the `shared-*` names for external consumers. Add a top-level module defining
`flake.modules.homeManager.<feature>` or `flake.modules.nixos.<feature>`, then
select it explicitly in a profile. For cross-cutting features, put system and
home definitions together. Inputs are captured by the top-level module, never
forwarded wholesale through `specialArgs`.

Monitors, Syncthing folders, fonts and timeout parameters remain typed. Shared
CLI and shell exports do not require the personal `home-config` option tree.
Package provenance remains stable nixpkgs plus the original selected master and
unstable overlays. Home Manager retains its own package set during migration.
The shared editor needs the consumer's matching Nixvim module. Theme/editor Lua,
snippets and launcher assets live in `assets/`; font archives remain local assets.

Hardware settings live in `modules/hosts/kitsune/hardware-configuration.nix`.
Regenerate into a temporary location with `nixos-generate-config --show-hardware-config`,
review differences, and copy hardware settings into that named module's body.
Do not overwrite the top-level wrapper or change stateVersion during upgrades.

## Validation and activation

Run from this checkout:

```sh
just check
just build
nix eval path:.#nixosConfigurations.kitsune.config.home-manager.users.kit.home.activationPackage.drvPath
```

`path:` includes newly created module files before they are added to Git. Private
SOPS input access and local proprietary font archives are required for the actual
host build, but not for minimal shared-feature consumers. `just build` creates
`result` without activating it. Read `docs/config-audit.md` and the Syncthing
transition below before explicitly running `just switch`.

Rollback after an explicit switch with `sudo nixos-rebuild switch --rollback`,
or select the previous generation from the boot menu. Retain the previous
working-tree snapshot and generation until the runtime checks pass.

## Syncthing ownership transition

The old user service is replaced by a system service running as `kit:users`.
Config and database paths remain `/home/kit/.local/state/syncthing`; its device ID
must remain the one recorded in `docs/migration/baseline.md`. Never delete or
regenerate key.pem/cert.pem or reset folder data. The mount guard verifies the
source device UUID and binds the service to `mnt-Media.mount`. Missing media
pauses **all** sync, including books and notes. After restoring media, explicitly
start/restart `syncthing.service` if needed. The GUI stays on localhost port 8385.
PrivateDevices is disabled for this service so the guard can resolve the expected
block-device symlink; the service still runs as the normal user with the NixOS
module's remaining sandbox settings.

Before activation, inspect current service ownership and preserve state backups
privately. Stop the old user service before allowing the system service to start:
`systemctl --user stop syncthing.service`. After activation verify that Home
Manager removed the old unit and only the system unit owns the process. Compare
`sudo -u kit syncthing device-id --home=/home/kit/.local/state/syncthing` with the
baseline before accepting any new pairing. Do not print private keys.

For rollback, stop the system service first, restore the previous NixOS/Home
Manager generation, and start the previous user unit only after confirming the
system unit is stopped. Both versions use the same state directory; keep a
private state backup before switching versions. No automatic live transition was
performed as part of implementation.

## Runtime checklist (pending until explicitly activated)

- Start Hyprland through UWSM; verify one SwayNC process and no Mako process.
  Send a notification and toggle SwayNC from Waybar. End the session and confirm
  its notification service stops.
- Inspect `systemctl --user status hypridle`; verify a single idle daemon.
  Invoke Hyprlock, authenticate successfully, and verify all visible lock actions
  use the same locker. Never test locking without a recovery session available.
- Suspend/resume and confirm locking before sleep and displays waking afterward.
  Timeouts remain display-off 1800s, lock 3600s and suspend 7200s.
- Check system Syncthing ID, GUI, folder paths, permissions and peers. Use the
  isolated VM test for absent/wrong mounts and normal unmount; do not unmount
  live source data to test deletion protection. Abrupt I/O failure is a separate
  recovery scenario and is not covered by normal-unmount guarantees.
- Check actual backup restore coverage separately; Restic client installation
  does not establish local scheduled backups.

If the first switch is performed inside an old Hyprland session, an unmanaged
SwayNC instance from that session may still own the notification bus name. Stop
that exact stale instance, then reset-failed/start the user swaync unit. This
handover was needed and verified during the migration; a fresh session must still
be checked for clean lifecycle behaviour. Completed runtime observations are
recorded in `migration/validation.md`.

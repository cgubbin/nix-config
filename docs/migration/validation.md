# Migration validation

Validated 2026-11-08 without switching the live system.

- `nix flake check path:. --no-build --no-write-lock-file`: passed.
- Kitsune NixOS system closure build: passed.
- Stable shared Home Manager environment build: passed.
- Work-pinned unstable shared Home Manager environment build: passed with the
  work consumer's existing see-cat C17 / Semgrep dependency overlays.
- Shared stable and unstable generated Git configuration contracts: passed.
- Kitsune generated Git, idle/resume, notification ownership, state-version,
  unselected-feature and Syncthing ownership/dependency checks: passed.
- Isolated NixOS VM test: passed unavailable-source rejection, correct-source
  startup, normal unmount stopping the service, wrong-source rejection and
  restart after restoration. No live disks were unmounted.
- Pre-commit Deadnix and Statix hooks: passed. Repeated dotted-prefix style
  suggestions are deliberately disabled; semantic diagnostics remain enabled.
- `git diff --check`: passed.

Logs and full evaluated snapshots are local in
`/tmp/kitsune-dendritic-baseline/` (not portable inputs). The initial VM fixtures
were corrected to use explicit mount units and an unavailable-source condition;
NixOS /etc unit precedence made runtime masking unsuitable. The initial unstable
build reproduced an upstream see-cat/glibc 2.44 failure, resolved in the fixture
using the already-existing work-repository workaround. Shared package definitions
and Kitsune's package set were not patched for that unstable-specific problem.

See comparison.md for evaluated package/service differences and baseline.md for
original identity/state facts. Existing source edits were migrated, not reset.

Still pending: explicit activation; live notification/session shutdown, Hyprlock
authentication and suspend/resume checks; verification of the new Syncthing
service's running state and public ID after activation; backup restore coverage;
actual adoption and host validation in the separate work repository. None of
these is implied by successful builds or synthetic consumer tests.

## Post-activation checks, 2026-11-08

User completed the switch after adding a five-entry systemd-boot limit.
`/boot` usage is now 461 MiB of 1022 MiB, with 562 MiB free. The running
system points to the November 5 nixpkgs generation. Active Nix settings now
include the Nix Community URL and published signing key alongside NixOS defaults.

- Syncthing system unit active as kit:users; old user unit inactive. Existing
  state directory remains owned by kit:users with mode 0700.
- Public device ID matches the baseline. Pi5 connected; iPhone remains paused.
  books (130 files), obsidian (463 files), and pi-media (87 files) are idle,
  with zero needed files/bytes and zero reported folder or recent system errors.
- Hypridle has one active user-service instance.
- The old session's unmanaged SwayNC process blocked the newly managed unit.
  It was stopped and the configured user unit started successfully. The user
  confirmed receiving the test notification and successfully toggling the panel.
  The unit is active and PartOf graphical-session.target. No Mako process found.
- No failed user units remain after the SwayNC handover.

Still pending: Hyprlock authentication, suspend/resume, a fresh UWSM session's
startup/shutdown lifecycle, and actual backup restore verification. The successful
system switch does not replace these manual checks. No lock, suspend, logout,
remote backup changes or disk unmount were triggered by the maintenance inspection.

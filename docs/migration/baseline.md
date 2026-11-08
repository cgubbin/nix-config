# Kitsune migration baseline

Captured 2026-11-08 before implementation. Existing tracked edits are preserved in
`/tmp/kitsune-dendritic-baseline/working-tree.patch`, with original lockfile and
status beside it. These temporary artifacts are local recovery material, not
portable build inputs. The tracked edits cover flake.lock, Syncthing, CLI tools,
AI tooling, Firefox, feature options and Kitsune's home configuration.

Baseline evaluation succeeded for system and Home Manager derivations:

- NixOS stateVersion: `25.05`; Home Manager: `26.05`.
- System: `/nix/store/19whnfsgc5p94ns9rrzyyah8dz64pij7-nixos-system-kitsune-26.05.20261025.1f607aa.drv`.
- Home: `/nix/store/046b5f02b1icl54216xcfp3lg7rlqqyh-home-manager-generation.drv`.
- Derivation evaluation is not a successful build or runtime verification.
- Home Manager warns that Waybar's `systemd.target` has become `systemd.targets`.

Syncthing is currently a failed user service. ExecStart uses Syncthing 2.1.3,
`serve --no-browser --no-restart --no-upgrade --gui-address=127.0.0.1:8385`.
Its state directory is `/home/kit/.local/state/syncthing`, owned by `kit:users`,
mode 0700. There is no `/home/kit/.config/syncthing` directory. Its public device
ID is `HXOHUD3-C6C4SU6-DMAPHVY-XCENNLS-EZ4WETQ-X45DESC-MSJ567J-MUCF5QF`.
Private identity files were not read or copied. No live services were changed.
The existing home configuration preserves that identity (`useIdentityFiles=false`).

A separate evaluated snapshot in `/tmp/kitsune-dendritic-baseline/evaluated.json`
records mount definitions, package store paths, service names, kernel/driver
versions, Syncthing folders and derivations for later comparison.

Baseline `nix build ... --dry-run` completed successfully without a build or activation.
After target retirement, the host output list is exactly `["kitsune"]` and
Kitsune still evaluates. Its derivation changes because the global Nix registry
tracks the input graph, from which retired inputs have been removed. Retained
lock nodes preserve their original locked revisions.

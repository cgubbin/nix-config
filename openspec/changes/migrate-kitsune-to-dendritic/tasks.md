# Tasks

## 1. Capture the working baseline

- [x] 1.1 Record current git status/diff and preserve the existing uncommitted edits; verify the baseline includes changes to Syncthing, Firefox, AI tools, feature options, tools, Kitsune, and flake.lock.
- [x] 1.2 Capture Kitsune's critical evaluated options, package provenance, service set, state versions, and system/Home Manager build results; verify a comparison artifact exists or records exact baseline failures and access blockers.
- [x] 1.3 Resolve current Syncthing config/data paths, owner, identity ID, folder definitions, and permissions without printing private keys; verify these facts are recorded for state-preserving migration and rollback.

## 2. Retire MacBook and work/WSL

- [x] 2.1 Remove retired host/home entrypoints, Darwin-only feature branches and imports, constructors/outputs, and exclusive direct inputs; verify machine outputs contain only Kitsune and source references have no live retired-target imports.
- [x] 2.2 Prune unreachable lock nodes without refreshing retained dependency revisions; verify retained revision comparison and lock graph reachability, then evaluate Kitsune.
- [x] 2.3 Limit maintenance outputs to x86_64-linux and simplify rebuild instructions/justfile for Kitsune; verify documented commands target the existing checkout, no Darwin branch remains, and emulation is preserved pending audit.

## 3. Introduce dendritic composition

- [x] 3.1 Add flake-parts, modules support, and import-tree confined to modules/; create the sole Kitsune constructor and explicit named feature/profile selection, and verify the flake evaluates.
- [x] 3.2 Migrate core Nix, users, SOPS, hardware, boot, GPU, firmware, network, power and system services into top-level feature modules; verify critical options and state versions against the baseline after this group of moves.
- [x] 3.3 Migrate CLI, development/cloud/AI tools, editors, GUI, fonts and theme into named features with typed parameters where useful; verify package/service differences against baseline and preserve current tool versions and selections.
- [x] 3.4 Migrate Hyprland, monitors, desktop services and Syncthing definitions while preserving effective behaviour before repairs; verify generated configurations and explain every difference.
- [x] 3.5 Remove superseded import trees, redundant enable options, and whole-input specialArgs forwarding; add an isolated unselected-feature check and verify discovery alone adds no packages or services.
- [x] 3.6 Document feature selection, extension, hardware regeneration and package provenance in maintenance documentation; verify examples match the actual new layout and run the lint checks on migrated files.

## 4. Repair Git and maintenance integration

- [x] 4.0 Separate shared Git behaviour from Kitsune identity before the Git repairs; verify a synthetic consumer identity composes without forced overrides.

- [x] 4.1 Correct generated Git sections and aliases using the pinned Home Manager API, install/configure Delta, protect main in the cleanup alias, and add SOPS; verify generated configuration with git config queries and tool availability in the built environment.
- [x] 4.2 Add a generated-Git regression check for aliases, pager, pull/rebase settings, and absence of misplaced container sections; verify it passes and document the intentional changes.
- [x] 4.3 Correct nh's checkout reference and validate pure evaluation before removing unconditional --impure; verify the documented build command evaluates and record any genuine remaining impurity requirement.
- [x] 4.4 Audit retained caches and keys against authoritative sources, correcting only demonstrated configuration errors; verify effective substituters/trusted keys and document any removed or retained cache rationale.

## 5. Repair desktop lifecycle

- [x] 5.1 Replace overlapping notification startup with one SwayNC service tied to the active Hyprland/UWSM session; verify generated units have the correct lifecycle, no Mako enablement or duplicate exec-once remains, and add a service-configuration check.
- [x] 5.2 Consolidate hypridle ownership, fix display wake arguments, accurately name display power-off, and align lock actions with Hyprlock/PAM while preserving timeout values; verify generated commands, PAM configuration, and unit ownership with checks.
- [x] 5.3 Document manual session start/stop, notification, authentication, idle, and suspend/resume checks; verify each has a concrete expected result and clearly mark runtime checks pending until performed without automatic activation.

## 6. Protect synchronized data and clarify backups

- [x] 6.1 Move Syncthing lifecycle to a single system service running as kit with explicit existing state paths and expected-mount dependencies/checks; verify device ID, folder settings, permissions, and removal of the competing user-service definition.
- [x] 6.2 Add an isolated systemd/VM test for absent mount at start, normal unmount while active, expected source identity, and restart after mount availability; verify no underlying-directory scan occurs without unmounting live media.
- [x] 6.3 Preserve the Restic client while removing misleading empty backup-service configuration where appropriate; verify generated configuration has no fabricated jobs and document absent local schedules and unverified external coverage.
- [x] 6.4 Document Syncthing ownership/state transition, rollback, and the trade-off that missing media pauses all sync; verify instructions preserve identities and data and contain no destructive reset steps.

## 7. Deliver configuration and package audit

- [x] 7.1 Write docs/config-audit.md with evidence, severity, disposition, and validation status for autologin, lock timing, firewall trust, Nix privileges, SSH backup access, SOPS bootstrap, recovery, storage/backup, and NVIDIA/device-path risks; verify all findings distinguish source observations from evaluated defaults and runtime facts.
- [x] 7.2 Assess Bluetooth/Blueman, polkit lifecycle, rtkit, trimming, disk health, restore checks, unused inputs/overlays/options, duplicate packages and unconditional services; verify each candidate is marked fixed, intentionally retained, recommended, or deferred with a reason, without enabling speculative services.

## 8. Validate the integrated result

- [x] 8.1 Run source lint, flake checks, all generated-configuration and mount-lifecycle tests, and explicit Kitsune/Home Manager evaluation; verify passing results or report exact external blockers without treating blocked checks as passed.
- [x] 8.2 Build Kitsune's system closure without activation and compare final packages, services and critical options with the working-tree baseline; verify every difference is accounted for by retirement or a documented repair.
- [x] 8.3 Review final diff for preserved user edits, secret/data protection, exclusive Kitsune outputs, and coherent architecture/audit/rollback documentation; verify deployment and runtime checks are explicitly separate from completed build-time validation.

## 9. Export and verify shared consumer features

- [x] 9.1 Export shared-git, shared-shells, shared-cli, and shared-editor under flake.modules.homeManager and consume them from Kitsune; verify both use the same definitions and consumer-specific identity, secret sourcing, browser paths, and editor extensions remain separate.
- [x] 9.2 Add minimal stable and pinned work-like unstable consumer fixtures with compatible Home Manager/Nixvim companion modules and consumer pkgs; verify public exports evaluate without Kitsune instantiation, private secrets, company inputs, or local workbench access.
- [x] 9.3 Add effective-configuration and representative build checks for both fixtures covering identity overrides, Git/Delta, shells/CLI, editor extensions, and absence of personal desktop/cloud/AI/secret defaults; verify checks pass before declaring exports supported and rerun Kitsune integration checks after shared extraction.
- [x] 9.4 Write docs/shared-features.md with tested pins, export names/dependencies, overlap and ownership map, and a staged adoption example using the work repo's flake-file declarations; verify examples replace overlapping starter/local modules, preserve work overrides, and describe regeneration, locked updates, pre-publication testing, and rollback.

## Workflow follow-up

- Adopt the exports in the independently owned work repository as a separate implementation change after the producer interface is available; evaluate/build that actual host with its authorized private inputs before claiming the repositories share their configuration.

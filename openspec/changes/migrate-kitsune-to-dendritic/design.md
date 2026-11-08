# Design

## Context

See proposal.md for motivation. The working tree already modifies flake.lock, Syncthing, common tools, AI tooling, Firefox, feature options, and Kitsune's home configuration; these are the baseline, not disposable changes. There are no existing durable specs.

flake.nix currently builds Kitsune, work/WSL, and MacBook through large constructors and passes inputs/outputs through two module layers. System and Home Manager features are split across hosts/common and home/kit. Kitsune uses Hyprland with UWSM, integrated Home Manager, Stylix, SOPS, Intel/NVIDIA offload, and a separate nofail media mount. No runtime or build verification has yet been performed.

## Goals / Non-Goals

**Goals:** Make feature ownership visible, preserve current operational state, and isolate intentional repairs from structural moves. Deliver an actionable audit with evidence, severity, disposition, and verification for each finding.

**Non-Goals:** Redesign disk layout, change state versions, replace Hyprland, rotate secrets or Syncthing identities, modify remote systems, deploy automatically, or choose new security/backup policies without a separate decision.

## Decisions

### Shared features across independently owned repositories

Read-only inspection of /home/kit/Repos/wsl-nix-config shows an existing flake-parts/import-tree layout with flake-file-generated flake.nix. modules/users/kit.nix imports CLI, cloud, direnv, Git, and LLM modules from a company starter plus local home modules. Work uses unstable nixpkgs and nixvim following that package set, unlike Kitsune's stable inputs. Local Git identity, SOPS templates, cloud credentials, workbench/kuiui, Windows Firefox, and a matched WezTerm binary are work-specific. Local tools contain unstable-specific build workarounds. The editor trees overlap but have diverged, including work-only plugin/input dependencies.

Expose flake.modules.homeManager.shared-git, shared-shells, shared-cli, and shared-editor as the initial public interface. Export definitions without enabling them globally; Kitsune imports the same definitions. Split Git identity from behaviour, general shell setup from secret sourcing and Windows/browser environment, and editor baseline from personal vault paths and work integrations. Keep AI/cloud bundles separately opt-in and outside the initial shared interface. Document each exported module's options, dependencies, and extension points. Do not merge divergent editor trees blindly: establish a common baseline and retain work-only additions as consumer extensions.

Shared modules use the consumer's pkgs. Document companion modules such as Nixvim explicitly; do not capture Kitsune's package set or require consumers to follow the producer's stable nixpkgs. Use independent stable and unstable consumer fixtures, with compatible pinned Home Manager/Nixvim versions for each. Pin the work-like set explicitly in test inputs and update it deliberately; support is limited to tested pins, not every unstable revision. Keep channel-specific workarounds local unless a compatibility test demonstrates they belong in the shared baseline.

Fixtures import the public exports into minimal Home Manager configurations with synthetic identities and editor extensions. Verify effective settings and representative builds on both input sets, including no leakage of personal identity, secret paths, desktop startup, or implicit AI/cloud services. They must not instantiate Kitsune or require company inputs, the private secrets input, or local workbench. Check the public module projection can be evaluated without fetching unrelated private inputs; flake metadata still exposes the producer's input graph, so do not claim the graph is dependency-free. If Nix's resolution makes a private input unavoidable, isolate the public module entrypoint/dependency graph before declaring consumer readiness.

Deliver docs/shared-features.md with an overlap/ownership table and staged work adoption: configure a pinned source input in the work repo's flake-file module declarations, regenerate flake.nix using its existing workflow, replace the corresponding starter/local import, retain work overrides, compare generated settings/packages, and update its lockfile deliberately. Start with Git/CLI before shells/editor. Avoid importing both competing baselines. Document local input overrides for pre-publication tests, revision updates, rollback, and breaking export changes. No upstream publication or work-repository edits occur in this change; actual adoption is a follow-up, and divergence is reduced only after that adoption.

Alternatives: a monorepo would contradict separate work-host ownership; a third shared repository adds publishing overhead. Exporting this repository's entire personal profile would leak machine assumptions and couple policies. The public feature boundary offers reuse while the work repository retains its company starter and host lifecycle.

### 1. Use a small flake-parts composition layer

Add flake-parts and import-tree, limiting discovery to modules/. Each maintained Nix file there is a top-level flake-parts module; lower-level NixOS and Home Manager modules are values under named module options. Explicitly import flake-parts' modules support. Use named feature modules and small composed profiles rather than creating a new bespoke framework. Closures capture inputs at the top level instead of forwarding the whole input/output graph through specialArgs.

Automatic discovery registers definitions; it must not enable all features. modules/hosts/kitsune.nix is the only machine constructor and selects a named Kitsune profile. Export maintenance tools for x86_64-linux only; preserve aarch64 emulation initially and audit whether it is still useful rather than assuming it belongs to WSL retirement.

Alternatives: retaining the current constructors keeps repeated wiring; introducing den or a larger framework adds abstractions unnecessary for one machine. A custom recursive importer saves one input but adds local infrastructure to maintain.

### 2. Group by feature, preserve meaningful parameters

Use modules/core/, modules/desktop/, modules/development/, modules/applications/, modules/services/, and modules/hosts/. A feature can declare both its system integration and home settings in one file. Larger features such as Neovim can span multiple top-level modules contributing to the same named feature. Keep monitors, Syncthing folders, and timeout parameters typed; remove redundant enable wrappers when explicit module selection replaces them.

Wrap Kitsune's hardware definitions as a host-specific module without changing UUIDs, mount semantics except the sync guard, kernel/driver selection, or workarounds. Preserve nixpkgs/HM package provenance during the move; defer useGlobalPkgs and package-source consolidation if they cause unrelated changes. Keep current stable/unstable/master pins unless an input is demonstrated unused. Preserve both stateVersion values.

Alternative: simply wrapping each old file retains the split ownership and conditional complexity that motivates this migration.

### 3. Retire targets by reachability

Remove hosts/macbook/, hosts/work/, their home entrypoints, Darwin-only modules/imports, constructors/outputs, direct WSL/Darwin/Homebrew/AeroSpace inputs, and the Darwin branch of justfile. Regenerate the lockfile while preserving retained revisions. Remove transitive nodes only when unreachable; a Darwin-related transitive dependency is not proof of incomplete retirement. Audit niri, impermanence, firmware overlays, stale options, and other candidates before pruning them. Do not modify the separate work or private secrets repositories.

### 4. Apply bounded integration fixes

- Git: flatten nested extraConfig into supported Git settings, move aliases to the valid alias section, use the pinned Home Manager Delta integration, and install sops. Validate the cleanup alias protects main before retaining it. Check actual pinned option definitions before implementation; earlier findings are source observations, not evaluated output.
- Notifications: retain SwayNC because Waybar and bindings already use it. Use one Home Manager/systemd service bound to the active Hyprland/UWSM graphical lifecycle, remove Mako and exec-once duplication, and align startup/shutdown targets.
- Idle/lock: use one lifecycle owner for hypridle, preserve timeout values, replace bare hyprctl with dispatch dpms on, rename misleading screenDimTime terminology, and use Hyprlock consistently with NixOS PAM integration. Validate authentication and suspend ordering in a later runtime check.
- Media sync: use a systemd dependency on the actual expected media mount, with startup verification and stop propagation. A directory-existence check is insufficient. Since Syncthing currently runs as a user service, prefer a system service running as kit, with a matching home directory and explicit existing config/data paths determined before migration, plus RequiresMountsFor/BindsTo/After and an ExecStartPre mount identity check. Preserve key/cert state and settings, avoid two instances, and document migration of service ownership. Blocking all sync while media is absent is an accepted conservative trade-off. Verify device-loss behaviour separately from normal unmount; do not promise recovery from arbitrary storage failure.
- Restic: preserve the client, remove empty service enablement if it generates no jobs, and document local schedules as absent. Remote Pi backup coverage is unverified.
- Maintenance: correct the nh checkout reference, attempt pure evaluation and drop unconditional --impure if no demonstrated requirement remains. Verify retained cache URLs and signing keys using authoritative sources during implementation; remove unused caches rather than copying stale keys.

### 5. Audit separately from policy changes

Write docs/config-audit.md containing observed evidence, impact, remediation/disposition, and verification status. Cover autologin, one-hour idle lock, broadly trusted Tailscale interface, trusted Nix user privileges, SSH/SFTP backup user scope, boot recovery, SOPS bootstrap, removable storage/sync, backup restore coverage, NVIDIA beta/kernel/power settings, unstable device paths, overlapping packages/services, unused inputs/options, and unconditional tools/services. For package/service gaps assess Delta, SOPS, Bluetooth/Blueman, polkit agent startup, rtkit, trimming, disk health, and restore checks. Distinguish modules' inherited defaults from explicitly missing features by inspecting evaluated configuration.

Only demonstrated integration repairs and Delta/SOPS installation are selected additions. Do not automatically enable Bluetooth, smartd, change firewall/SSH policy, shorten lock times, disable autologin, or create backup destinations. Record those as recommendations/deferred decisions. This preserves a reviewable migration while satisfying the requested gap analysis.

## Risks / Trade-offs

- Existing config may fail evaluation -> capture the exact baseline failure and isolate prerequisite fixes before comparing; never call a failed baseline equivalent.
- Private SSH input or proprietary font assets may block reproducibility -> document required access without exposing secret content; report blocked checks precisely.
- User-service to system-service Syncthing migration may change paths/permissions -> inspect effective current paths and IDs, stop the old owner before starting the new owner, preserve state, and provide rollback instructions.
- Generated hardware files normally remain standalone -> wrap definitions carefully for the dendritic tree and document regeneration without reintroducing direct lower-level imports.
- New automatic imports can activate unintended config -> put side effects inside explicitly selected named modules and verify an unselected fixture remains inactive.
- New formatting can obscure substantive edits -> keep structural movement and behaviour fixes reviewable separately; do not reformat unrelated files.
- Stable/unstable APIs and editor trees differ -> test pinned consumer configurations, preserve consumer extensions, and treat compatibility failures as blockers for the affected export.
- Exporting code does not migrate the work consumer -> provide a concrete replacement map and follow-up adoption steps; do not report divergence resolved before the consumer switches.

## Migration Plan

1. Capture git diff/status and baseline evaluated critical settings, packages, services, Syncthing paths/identity, and build results or blockers without touching the live system.
2. Remove retired targets and their exclusive dependencies; verify Kitsune still evaluates and retained revisions remain pinned.
3. Introduce composition and migrate features with baseline parity; resolve each difference explicitly.
4. Apply integration fixes, produce the audit, and add meaningful generated-output/service-dependency checks.
5. Run lint, flake checks, explicit system/HM evaluation, and a Kitsune system build without activation. Validate missing-mount behaviour in an isolated systemd/VM fixture, not by unmounting live data.
6. Document subsequent manual session tests, activation, and rollback. A deployment is a later user action. Rollback uses the previous NixOS generation and previous Syncthing service owner/state paths; never delete identity or folder data. Runtime checks remain clearly pending until actually performed.

## Open Questions

No blocking design questions. Exact installed Syncthing state paths, inherited maintenance defaults, and private-input availability are implementation verification facts; their results determine concrete wiring or audit status, not the intended behaviour. User policy preferences and optional service additions remain deferred recommendations outside this implementation.

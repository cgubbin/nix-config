# Configuration audit

Inspected 2026-11-08. Baseline evidence is in `migration/baseline.md`; evaluated
options were captured locally under `/tmp/kitsune-dendritic-baseline/`. Source
observations are not claims that runtime behaviour was reproduced. No live
activation, remote peer changes or external backup verification occurred.

| Area | Evidence / impact | Disposition |
| --- | --- | --- |
| Git (medium) | Settings containers and Delta enablement were nested as Git settings; pager binary was not explicitly provided. | Fixed shared Git settings, aliases, main-protected cleanup and Delta integration; generated config checks cover actual values. |
| Notifications (medium) | Mako enabled alongside SwayNC, with SwayNC also launched via exec-once and tied to a Sway target. | SwayNC selected once via graphical-session lifecycle; runtime session test remains required. |
| Lock/resume (medium) | Bare hyprctl after sleep; display-off described as dimming; mixed locker commands. | Valid DPMS wake, accurate name, consistent Hyprlock. Evaluated PAM integration exists. |
| Autologin / timing (high physical-access exposure) | Autologin true; idle lock 3600s, display off 1800s. | Retained policy; recommend disabling autologin and selecting a shorter lock delay. No policy choice assumed. |
| Media sync (high data risk) | Source is on a nofail disk; send-only media has no versioning. | Source identity guard and mount-bound system service; isolated tests cover normal absence/unmount. All sync pauses without media. Existing identity, peers and folders retained. |
| Existing sync failure (medium) | User unit was already failed at inspection. | Recorded baseline; migration is not evidence that the original runtime failure was diagnosed or repaired. Verify after explicit activation. |
| Backups / restore (high) | No local Restic jobs/repository/retention configured. | Client retained; empty service enablement removed. External Pi backup coverage and restore ability remain unverified. Select scope/destination/retention in a separate decision. |
| Tailscale firewall (medium) | tailscale0 is a trusted interface, allowing traffic beyond individual opened ports. | Retained; review against actual tailnet ACLs before restricting. |
| Nix privileges (high trust) | root and kit are trusted Nix users. | Retained; kit can exercise privileged daemon capabilities. Remove that trust if unnecessary after reviewing workflow. |
| SSH backup account (medium) | SFTP forced, no forwarding/PTY, no chroot; backup account has its normal Unix permissions. | Retained; review read access and key scope. No claim that forced SFTP is filesystem confinement. |
| SOPS / recovery (high operational dependency) | Password depends on private encrypted input and host age/SSH identity bootstrap. | Preserve keys and recovery instructions privately; verify recovery access before reinstalling. No secret rotation or private-repo edits. |
| Cache configuration (medium) | Evaluated trust included only NixOS key; extra caches were configured without keys. CUDA cache returned HTTP 401 during checks. | Remove unused AI/CUDA caches, use NixOS defaults plus documented Nix Community URL/key. See https://nix-community.org/cache/ for authoritative configuration. |
| GPU/kernel (medium) | NVIDIA beta, pinned 6.18 kernel, offload and firmware/ACPI workarounds. | Retained to preserve hardware behaviour; test suspend and thermal/power behaviour before changing drivers. |
| Device ordering / Wayland (medium) | WLR_DRM_DEVICES uses card numbers; forced Wayland variables also come from the old Niri-labelled system module. | Retained, recommend stable by-path device selection and reviewing global backend forcing. Do not assume unused flake input means its legacy environment module was unused. |
| SSD trimming (low) | services.fstrim.enable evaluates true. | Already covered; no redundant addition. |
| Disk health (medium) | services.smartd.enable evaluates false. | Recommend drive-aware health monitoring after checking actual devices, including USB SMART capability; not auto-enabled. |
| Realtime audio (low) | security.rtkit.enable false with PipeWire selected. | Candidate addition if scheduling/dropouts warrant it; no runtime symptom established. |
| Bluetooth (low) | Bluetooth and Blueman disabled, while a launcher action references Blueman. | Recommend enabling both if Bluetooth is used, otherwise removing the action; package availability alone is insufficient. |
| Polkit (medium) | security.polkit.enable true; hyprpolkitagent installed. | Verify agent startup in active session; installation is not proof of a running agent. |
| Fonts / stale flags (low) | Berkeley option selected but package block commented out; several font expressions were unused. | Preserve actual package selection; remove unused expressions, retain archives. Recommend deciding whether to actually install Berkeley rather than assuming the flag worked. |
| Duplicate tools / services (low) | Restic, VLC and nix-direnv have overlapping package sources; broad development bundle includes cloud tools. | Duplicates coalesce in profiles; retain package selection during migration. Split cloud/AI selection explicitly before work adoption. Ollama's Linux module was not imported, so it was not enabled merely by selecting dev tools. |
| Shared drift (medium) | Work uses unstable, company starter, local editor additions and build workarounds. | Shared exports and two pinned consumer fixtures; actual work adoption remains separate. Compatibility is limited to tested pins, not arbitrary unstable revisions. |
| Ctrl-R ownership (low) | Unstable HM warns that FZF and Atuin both integrate with fish/Nushell; Atuin is sourced last. | Retain current behaviour and document Atuin owns Ctrl-R; consumers can choose their binding. |

Optional additions are recommendations, not installed packages. Delta and SOPS
are selected integrations because existing configuration already depends on them.
The audit distinguishes inherited defaults from explicit source settings; runtime
session, backup restore, and hardware checks remain in MAINTENANCE.md.

## Retained cleanup candidates

- The `niri` and `impermanence` flake inputs have no active module references.
  They are retained at their existing revisions for this migration; pruning them
  is a recommended dependency cleanup, not an assertion that those capabilities
  are active. The separately selected Niri-labelled system file still sets global
  backend variables and must not be removed on that basis alone.
- `sofFirmwareUnstable` is an unused overlay attribute; retain for provenance
  comparison, then remove in a focused cleanup if no intended caller needs it.
- Unselected registered modules (the old alternate display-manager/user definitions,
  Mako, Ollama, and gaming home fragment) have no host effect. They are available
  definitions, not enabled services. Typed legacy switches outside the shared CLI
  remain as compatibility parameters; future simplification should remove them
  with their consumer references together. The redundant shared CLI enable switch
  was removed because selecting that profile is sufficient.
- Statix's repeated-prefix style suggestion is disabled in statix.toml to preserve
  readable dotted hardware settings. Semantic lint diagnostics remain enabled.

# Proposal

## Why

The repository still supports a retired MacBook and a WSL machine now managed elsewhere, while Kitsune features are scattered across system and Home Manager trees. Consolidating around Kitsune and feature-oriented modules makes maintenance easier and provides an opportunity to correct demonstrated integration defects and document remaining gaps.

## What Changes

- Adopt a dendritic layout using flake-parts and automatically discovered top-level feature modules, with explicit feature selection for Kitsune.
- Export opt-in shared Home Manager features for the separate work repository, with consumer-owned identity/settings, pinned updates, and stable/unstable compatibility checks. Document staged adoption without changing the work repository in this change.
- **BREAKING**: Remove MacBook and work/WSL host outputs, host/home files, Darwin branches, and dependencies used exclusively by retired targets. Preserve dependencies still reachable from retained inputs.
- Preserve Kitsune hardware, state versions, user data, secrets provisioning, application selections, and existing uncommitted configuration changes during structural migration.
- Correct Git/Delta integration, consolidate notification startup around SwayNC, repair idle resume commands, and prevent media synchronization against an absent media mount.
- Make backup coverage explicit rather than implying that an enabled Restic module establishes scheduled backups.
- Produce an evidence-based audit of security, reliability, unused dependencies, and useful missing packages/services, distinguishing fixes from recommendations needing user decisions.
- Add reproducible evaluation/build checks and document rebuild and rollback procedures.

## Capabilities

### New Capabilities

- `host-composition`: Supported host outputs, explicit feature composition, shared consumer exports, and configuration preservation.
- `desktop-session`: Notification ownership and working lock/resume integration.
- `developer-tooling`: Generated Git configuration and required tool availability.
- `data-protection`: Mount-aware synchronization and accurate backup coverage reporting.

### Modified Capabilities

None; the project currently has no durable specs.

## Impact

Touches flake.nix, flake.lock, hosts/, home/, justfile, new modules/, and maintenance/audit documentation. Adds flake-parts and an import-tree helper; removes direct Darwin/Homebrew/AeroSpace and WSL dependencies. Kitsune remains the sole host and retains its state versions. The separate work repository is a read-only reference for shared exports and compatibility fixtures; its host, secrets, company starter, and eventual adoption remain independently owned. No changes to that repository, private secrets, Pi configuration, remote peer state, or live activation are included. New backup destinations, security policy changes, and speculative package additions remain recommendations.

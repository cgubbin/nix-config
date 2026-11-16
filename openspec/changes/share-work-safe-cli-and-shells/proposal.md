# Proposal

## Why

The personal and work configurations duplicate Git, shell, CLI and Zellij settings, while the existing shared CLI bundle includes automatic Atuin sync and is unsuitable for the work machine. Shell helpers also contain stale host assumptions and actions that need clearer safeguards.

## What Changes

- Split CLI exports into an independently selectable work baseline and optional features; exclude Atuin and history synchronization from the work selection while preserving personal behavior.
- Remove stale machine-specific rebuild aliases, require preview or explicit intent before replaying shell history, and avoid automatic approval of project `.envrc` files.
- Prepare reviewed adoption of shared Git, CLI and Zellij in the work configuration, preserving work-specific settings and validating on the actual work host.
- Evaluate notebook-aware diffs, structural diffs and local secret scanning against existing project and company tooling; document choices and add useful tools without silently changing global Git behavior.
- Keep personal machine security and maintenance decisions outside this change.

## Capabilities

### New Capabilities

- `shared-command-line-workflows`: Selectable CLI and shell features, local history boundaries and safe work adoption.

### Modified Capabilities

None.

## Impact

Shared Home Manager modules, Fish helpers, consumer fixtures and shared-feature documentation may change. Existing consumers need a compatibility and migration review. The separate work repository and real WSL host require their own review and validation; no identity, secrets, Windows integration or personal notes are moved between machines.

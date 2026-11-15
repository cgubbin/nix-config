# Design

## Context

`shared-cli` imports Atuin with automatic sync and a broad tool bundle. `shared-shells` imports Fish, Nushell and direnv; Fish contains other-host rebuild aliases, a history replay helper and project creation that approves `.envrc`. Work's inspected snapshot has similar settings plus a Git cleanup alias that does not protect `main`. Its actual current host and private inputs are unavailable here. Existing shared Git and Zellij exports already provide migration starting points.

## Goals / Non-Goals

**Goals:** Make work-safe CLI selection explicit and composable; preserve personal behavior and host ownership; test the work selection with consumer package sets.

**Non-Goals:** Ban local history; change work security policy, install services or modify the actual work host during planning; alter personal autologin, backups or other separate maintenance decisions; force global notebook diff or merge drivers.

## Decisions

- Export a common CLI baseline separately from optional Atuin and other broad extras. Preserve the current `shared-cli` compatibility contract or explicitly migrate every existing consumer, particularly Kitsune, without changing personal Atuin settings. Verify transitive imports and generated settings, not just module names. Local Fish/Nushell history is allowed; no offsite history sync and no Atuin in the work selection.
- Remove or consumer-parameterize stale rebuild aliases. Change history replay to preview by default with an explicit execution flag, and change project creation to request manual review and approval of `.envrc`. Test non-execution and opt-in behavior using disposable fixtures.
- Work adoption should use reviewed shared Git and Zellij exports and the new CLI baseline, retaining work identity, Git ignores, Windows wrappers, secrets sourcing, overlays and company starter choices. Remove or exclude overlapping definitions explicitly rather than using blanket overrides. Keep personal and work inputs and lockfiles under their respective owners' control.
- Evaluate nbdime and Difftastic as explicit review commands, including package availability at both pins; evaluate a local secret scanner against existing company tooling and policy. Do not enable Git merge drivers globally or make automated network calls. Keep Python project dependencies in project environments.
- Test declarative fixtures for stable and work-like inputs, and distinguish those from actual Windows/WSL validation. Produce a reviewable migration or patch using the current work baseline and provide rollback instructions; actual adoption depends on the work machine and permission to modify its repository.

## Risks / Trade-offs

- [An indirect import re-enables history sync] -> Check evaluated work modules and generated shell settings for Atuin and synchronization configuration, then inspect the real work host separately.
- [Existing consumer behavior changes] -> Test personal and work-like compositions before and after, document compatibility and avoid silently changing the existing export.
- [Repository snapshots or company packages differ] -> Recheck actual work revision and host configuration before migration; do not copy private data or credentials.
- [Tool integration modifies Git behavior] -> Start with explicit commands and test any proposed Git integration in disposable repositories.

## Migration Plan

Build both shared-consumer fixtures and Kitsune without activation. Publish a reviewed revision, then separately update the work repository input and remove overlapping modules on the work laptop; build and inspect before activation. Roll back using the prior work source and lockfile and the prior personal system generation.

# Proposal

## Why

Kitsune and the separately managed work WSL repository contain divergent copies of a substantial Nixvim configuration. Work's newer Python, debugging and notebook integrations should lead the shared configuration, while a focused audit addresses defects before both machines depend on it.

## What Changes

- Establish one work-first shared Nixvim baseline for Kitsune and work, preserving work's newer intended behaviour and retaining machine-specific vault, terminal and work integrations as explicit extensions.
- Audit Nixvim for configuration defects, missing integrations and useful capabilities; fix the demonstrated notebook overwrite, project-environment, interpreter fallback, duplicate completion and stale path issues, and document findings and deferred recommendations.
- Make Python/Pixi, DAP/Neotest and notebook/Quarto integrations reusable and compatible with the existing stable and work-pinned unstable consumers; keep private or host-specific dependencies optional and explicit.
- Create and test a reviewable work-repository adoption patch and instructions: retain the work Nixvim companion and pins, prevent recursive re-import of the former editor tree, and preserve work-only behaviour. Applying the patch to the separate repository and validating its real WSL host is a required integration follow-up outside this repo-local change's edit roots.
- Add meaningful headless and project-level checks covering startup, completion, interpreter selection, environment isolation, tests, debugging, notebook safety and both consumer pins. Document update and rollback procedures.

## Capabilities

### New Capabilities

- `shared-nixvim`: Shared editor composition, consumer adoption and compatibility across Kitsune and work.
- `nixvim-project-workflows`: Safe project environments, Python testing and debugging, and notebook workflows.

### Modified Capabilities

None. No main specs exist; the completed, unarchived `migrate-kitsune-to-dendritic` change defines the current shared export and supplies relevant context.

## Impact

Changes this repository's shared Nixvim modules, assets, fixtures, checks, documentation and a reviewable consumer patch. The intended downstream target is `/home/kit/Repos/wsl-nix-config`, especially its generated-flake source declarations and recursively imported home tree; the actual work repo is outside the current OpenSpec edit root and needs a separate authorized application and actual-host verification. Existing stable Kitsune and work-pinned unstable dependency stacks remain distinct; no automatic host activation, publishing, secrets changes, or broad Git/shell/CLI unification is in scope. The current work behaviour is the precedence baseline except for explicit, documented corrections.

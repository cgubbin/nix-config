# Proposal

## Why

The shared editor assumes recipe names and directly runs Python tools, whereas work projects expose a unified Just interface and use Nox to create isolated environments from lockfiles. The editor must make those project-owned workflows accessible without implying that an unrelated interpreter reproduces a Nox session.

## What Changes

- Discover actual Just recipes and expose them as explicit, project-scoped tasks, with arguments and actionable errors.
- Support project-owned Nox test/check workflows and transparent test/debug environment selection; do not silently substitute a different interpreter.
- Support uv and Pixi environments, including explicitly selected Pixi environments, with visible diagnostics and no implicit dependency installation.
- Reconcile editor Python diagnostics and formatting with project environments, and document residual limitations.
- Exercise representative disposable fixtures; validate private work projects later on the actual work machine.

## Capabilities

### New Capabilities

- `project-owned-editor-workflows`: Project task discovery, environment selection, and Python editing, testing and debugging integration.

### Modified Capabilities

None; the previous editor change has not been synced to the main specs.

## Impact

Shared Nixvim Lua and Nix modules, consumer checks, and user documentation. Existing work projects and their lockfiles are not modified. Direct pytest remains available only as a clearly identified workflow, not as proof of a Nox run.

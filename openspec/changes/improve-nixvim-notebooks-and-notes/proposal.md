# Proposal

## Why

Working with notebooks in Neovim requires repeated kernel selection, fragmented controls and a browser preview to see plots on the work laptop. Quick Org notes also require leaving the editor even though Doom remains the preferred place for full note management.

## What Changes

- Make notebook kernel selection project-aware and automatic when the correct choice is unambiguous, with explicit selection and useful errors otherwise.
- Evaluate and configure notebook output rendering for Windows Terminal and Zellij, including an honest fallback if inline images cannot be supported on the installed versions.
- Retain the notebook Hydra as the primary menu, simplify overlapping mappings, and verify notebook output persistence.
- Provide lightweight access to create or edit notes in the consumer's existing Org directory while preserving Doom as the primary Org and Org-roam environment.
- Validate real uv, Pixi, Just/Nox and Claude workflows on the work laptop; document observed gaps rather than inventing project conventions.

## Capabilities

### New Capabilities

- `editor-notebook-workflows`: Project-aware notebook execution, controls, output and persistence.
- `editor-org-quick-notes`: Quick note access and creation in the existing host-specific Org store.

### Modified Capabilities

None.

## Impact

Shared Nixvim notebook and note modules, consumer-specific options, tests and documentation may change. Actual Windows Terminal, Zellij, project environments and Claude integration require validation on the work laptop. Existing Doom note files and project-owned task conventions remain authoritative; private project material must not be copied into this repository.

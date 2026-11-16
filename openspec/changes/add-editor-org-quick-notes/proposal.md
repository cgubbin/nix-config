# Proposal

## Why

Writing a quick Org note means leaving Neovim, even though Doom remains the preferred place for full note management. A lightweight way to open and create notes in the consumer's existing Org directory would remove that context switch without duplicating Doom.

Split from `improve-nixvim-notebooks` (originally `improve-nixvim-notebooks-and-notes`), whose remaining scope is notebooks only.

## What Changes

- Provide editor access to existing notes in the consumer's configured Org root and creation of simple new notes there.
- Keep quick notes as ordinary Org files compatible with Doom; only advertise Org-roam nodes if stable IDs and Doom discovery are verified.

## Capabilities

### New Capabilities

- `editor-org-quick-notes`: quick note access and creation in the existing host-specific Org store.

### Modified Capabilities

None.

## Impact

Shared Nixvim modules and a consumer option for the Org root (likely reusing the existing `knowledge.orgDirectory`), tests and documentation. Existing note files and Doom workflows remain authoritative.

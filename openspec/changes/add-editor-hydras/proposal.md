# Proposal

## Why

Several editor workflows are loops of short, repeated actions behind long leader sequences: stepping a debugger means pressing `<leader>dn` repeatedly, reviewing Git hunks alternates `]c` with `<leader>hs`/`<leader>hr`, and resizing windows uses four separate mappings. The Hydra plugin, already enabled for the notebook menu, keeps a mode active so each step is one key.

This change is optional: adopt individual menus only if they prove useful once the notebook Hydra is in daily use (see `improve-nixvim-notebooks`).

## What Changes

- Add a debugging menu over the existing nvim-dap mappings: step over, step into, step out, continue, toggle breakpoint, hover and terminate.
- Add a Git hunk review menu over the existing gitsigns actions: next and previous hunk, stage, reset, preview and blame.
- Add a window resize menu with `h`/`j`/`k`/`l`.
- Keep every existing direct mapping; the menus are additional entry points.

## Capabilities

### New Capabilities

- `editor-repeatable-menus`: modal menus for repeated debugging, hunk review and window actions.

### Modified Capabilities

None.

## Impact

Shared Nixvim Hydra configuration and which-key descriptions. No changes to plugin behaviour or existing mappings.

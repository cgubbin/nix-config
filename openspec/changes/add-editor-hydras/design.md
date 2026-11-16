# Design

## Context

`plugins.hydra` is enabled with one notebook Hydra (`plugins/notebook.nix`). The existing mappings the new menus would cover:

- **DAP** (`plugins/dap.nix`): `<leader>d` plus `s`, `c`, `n`, `i`, `o`, `b`, `C`, `l` and `e`.
- **gitsigns** (`plugins/gitsigns.nix`): `]c`/`[c`, plus `<leader>h` with `s`, `r`, `S`, `u`, `R`, `P`, `b` and `t`.
- **Window resize** (`keymappings.nix`): four `:resize` mappings.

## Goals / Non-Goals

**Goals:**
- One-key repetition inside a visible mode.
- Discoverable hints.
- No collisions with existing mappings.

**Non-Goals:**
- Changing DAP, gitsigns or window behaviour.
- Removing existing mappings.

## Decisions

- **Debugging.** Use a pink Hydra on `<leader>D`, chosen to avoid the `<leader>d` group:
  - `n` step over, `i` step into, `o` step out, `c` continue
  - `b` toggle breakpoint, `h` hover, `e` terminate
  - `q`/`<esc>` exit
  - Optionally exit automatically when the session ends.
- **Git hunk review.** Use a pink Hydra on `<leader>H`:
  - `j`/`k` next and previous hunk, `s` stage, `r` reset, `p` preview, `b` blame line, `u` undo stage
  - `q`/`<esc>` exit
- **Window resize.** Use a pink Hydra on `<C-w>r` (or another free key, checked for collisions): `h`/`j`/`k`/`l` resize by 2, `=` equalize, `q`/`<esc>` exit.
- **Shared conventions.** Each Hydra shows a hint window and appears in which-key.
- **Demand check.** Implement each menu only after confirming it would be used, starting with debugging.

## Risks / Trade-offs

- **[Key collisions]** → Check generated mappings for conflicts before choosing body keys.
- **[Mode confusion]** → Hint window always visible, with `q`/`<esc>` exit in every menu.

## Migration Plan

Additive only. Build both pinned shared-editor consumers and Kitsune without activation. Roll back by reverting the producer revision.

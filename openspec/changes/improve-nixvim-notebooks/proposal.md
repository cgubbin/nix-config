# Proposal

## Why

Notebooks in the shared Neovim editor run in the wrong interpreter: the only kernel Molten can see is the `python3` kernelspec from Neovim's own Nix Python host, so project imports fail or differ silently. Plots never render inline (Molten's image provider is `none`), which forces a Quarto preview in the browser for every look at a figure. That preview needs per-call temporary-file setup and leaves `*_files/`, `.quarto/` and `*.quarto_ipynb` artefacts that must be kept out of Git. Notebook controls are split across three overlapping key layers, save errors are swallowed, and a `PYTHONPATH` workaround puts the current directory on every child Python's import path.

Work-laptop checks on 2026-11-16 showed the missing pieces are achievable on the pinned versions: Windows Terminal 1.25 inside Zellij 0.45 displays Sixel, image.nvim's `sixel` backend renders there, and Molten routed through image.nvim displays a matplotlib plot from a project kernel started via a generated kernelspec.

## What Changes

- Start notebook kernels in the selected project environment, one per project root or worktree, by generating kernelspecs from the editor's existing environment selection and captured direnv environment, without writing to the project or the user's Jupyter data directory.
- Make `# %%` (Jupytext percent) `.py` files the primary notebook editing format, run directly by Molten; keep `.ipynb` editing through Jupytext as an import/export path.
- Render notebook images inline through image.nvim, with the backend chosen by the consumer (`sixel` for the work laptop), and a documented fallback.
- Surface save and export failures, and show outputs already stored in an `.ipynb` when it is opened.
- Make the notebook Hydra the primary control surface with a run-and-advance action, keep direct run-cell and interrupt keys, and remove duplicate mappings.
- Provide one command that renders the current document with Quarto to a temporary directory outside the repository and opens it in the browser.
- Remove the `PYTHONPATH` workaround or make it correct (no empty entry, no duplicates).

Quick Org notes move to `add-editor-org-quick-notes`. Other Hydra menus (debugging, Git hunk review, window resizing) move to `add-editor-hydras`. A team-wide policy on notebook formats belongs in the team's own repositories and is out of scope here.

## Capabilities

### New Capabilities

- `editor-notebook-workflows`: project kernels, percent-format notebooks, inline output, persistence, controls and temporary rendering.

### Modified Capabilities

- `project-owned-editor-workflows`: notebook kernels join the Python integrations that use the selected project environment.

## Impact

Shared Nixvim notebook module and Lua helpers (`kit.notebook`, `kit.python_env`, `kit.project_env`, `kit.jupytext_safe`), the `sharedEditor.imageBackend` default and documentation, consumer settings (the work consumer selects `sixel`), and headless tests. Projects, their environments and their Git configuration are not modified.

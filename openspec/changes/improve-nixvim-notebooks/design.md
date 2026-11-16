# Design

## Context

The shared editor wires Quarto, Jupytext, Molten, otter and image.nvim (`modules/applications/nixvim/plugins/notebook.nix`). Observed state on the pinned versions:

- **Kernels.** Molten's host is Neovim's Python environment. `MoltenAvailableKernels()` returns only `python3`, provided by that environment's own `ipykernel`. No project kernelspecs exist and `jupyter` is not on `PATH`. `kit.python_env` already discovers `.venv`, `.pixi/envs/*` and Nox environments per project root and remembers the selection; LSP, DAP and Ruff use it. `kit.project_env` already captures the project's environment with `direnv export json`.
- **Output.** `image_provider = "none"`; image.nvim's backend comes from `sharedEditor.imageBackend` (default `kitty`).
- **Persistence.** Jupytext converts `.ipynb` to a temporary Markdown buffer (`kit.jupytext_safe` keeps the scratch file out of the project). A `BufWritePost` autocommand runs `MoltenExportOutput` inside `pcall`, so failures are silent. Nothing imports existing outputs on open.
- **Controls.** A Hydra on `<localleader>j`, buffer maps under `<localleader>r`, `m` and `q`, and global `<leader>q*` maps that duplicate the buffer `q*` maps. The Hydra lacks interrupt; `j` re-runs the current cell rather than advancing.
- **Workaround.** `extraConfigLuaPre` appends Molten's `rplugin/python3` to `PYTHONPATH`, producing a leading empty entry (the current directory) and a duplicate path for every Python process Neovim starts.

### Work-laptop evidence (2026-11-16)

Each layer was tested with disposable files outside any project:

| Layer | Result |
|---|---|
| Windows Terminal 1.25, no multiplexer | DA1 reports `4` (Sixel); ImageMagick Sixel output renders |
| Zellij 0.45.1 normal pane | Renders |
| Zellij floating pane | Large images escape the pane until it is closed; avoid for notebooks |
| image.nvim `backend = "sixel"` | Renders; hides on scroll-off and window overlap (`window_overlap_clear_enabled`) |
| Molten `image_provider = "image.nvim"` | Displays a matplotlib plot from a project kernel |
| Kernelspec on a temporary `JUPYTER_PATH` | Molten finds and starts it; kernel reports the project's `sys.executable` and the inline backend |

Two constraints came out of the kernel test:

1. In the tested uv worktree project, `.venv/bin/python` imports `pyzmq` only inside the project's direnv environment. That environment comes from a company Nix flake, which supplies native libraries. A kernel started without it fails before running any code.
2. Starting the kernel through `direnv exec <root> …` works, but re-runs the flake's shell hook on every kernel start. In the tested project that hook runs `uv sync` and prints debug output, which violates "No automatic project mutation".

Two test-tooling pitfalls are also worth recording. A shell alias of `cat` to `bat` mangles raw escape output (use `command cat`). And `MoltenEvaluateRange` is a function, called as `vim.fn.MoltenEvaluateRange(kernel, start, end)`, not an Ex command.

## Goals / Non-Goals

**Goals:**
- Notebooks run in the project's selected interpreter, or fail with an actionable message.
- Plots are visible in the editor on the work laptop.
- Percent-format `.py` notebooks are first class.
- Failures are visible.
- Fewer, non-overlapping controls.

**Non-Goals:**
- Installing `ipykernel` or other dependencies.
- Registering kernels in the user's Jupyter data directory.
- Changing project Git configuration.
- Making a team-wide format policy.
- Supporting images in Zellij floating panes.
- Replacing Quarto for report rendering.

## Decisions

### Kernels: generated kernelspecs from the selected environment

- **Kernelspec directory.** Use a kernelspec directory under Neovim's run directory (`stdpath("run")/jupyter/kernels`). Prepend its parent to `JUPYTER_PATH` before Molten's Python host starts, i.e. early in startup. The host reads its environment once, but jupyter_client rescans the directory on each lookup, so specs written later are found.
- **When a notebook opens:**
  - Resolve the project root with `kit.project` (a worktree is its own root) and the environment with `kit.python_env`.
  - Write a spec named from the root and environment, e.g. `<root-basename>-<env>-<short-hash-of-root>`, with a readable `display_name`.
  - `argv` runs the environment's interpreter directly: `<env>/bin/python -m ipykernel_launcher -f {connection_file}`. Pixi environments use `.pixi/envs/<name>/bin/python`.
  - The spec's `env` carries the environment captured by `kit.project_env` (`direnv export json`) and, for Pixi, the activation variables `kit.python_env.apply` computes. The kernel then never re-runs `direnv` or shell hooks.
- **Choosing a kernel.** Start the generated kernel automatically when the project and environment are unambiguous. Otherwise use the existing environment picker. An explicit `:MoltenInit <name>` still works.
- **Missing pieces.** If the interpreter lacks `ipykernel`, or the direnv environment is unapproved or unavailable, report it with the exact preparation command (`uv add --dev ipykernel`, `pixi add ipykernel`, `direnv allow`) and do not fall back to `python3`.
- **Showing identity.** Show the kernel's identity (spec name and `sys.executable`) after start.
- **Alternatives rejected:**
  - `ipykernel install --user` mutates user state and goes stale across worktrees.
  - `direnv exec` in `argv` re-runs hooks (see the evidence above).
  - Starting kernels externally and attaching by connection file adds process management for no gain.

### Percent-format `.py` notebooks are primary

Molten evaluates `# %%` cells in `python` buffers directly. Add a cell-range helper (from the cursor to the next `# %%`) for run-cell, run-and-advance and run-above. Outputs live in the editor session.

`.ipynb` files still open through Jupytext for import and export. Paired `.ipynb` files are produced by explicit Jupytext commands, never implicitly on save.

### Output: image.nvim with a consumer-selected backend

- Set Molten `image_provider = "image.nvim"`.
- Keep `sharedEditor.imageBackend` as the backend selector, documenting `sixel` for Windows Terminal (1.22+) with Zellij and `kitty` for Kitty-protocol terminals.
- The work consumer sets `sixel`.
- Keep `window_overlap_clear_enabled = true`.
- Keep the browser and Quarto paths as fallbacks for rich or interactive output.

### Persistence

- Replace the `pcall`-wrapped export with an explicit path that reports errors.
- Determine the correct ordering relative to Jupytext's `.ipynb` write before changing behaviour.
- Import stored outputs when an `.ipynb` opens (`MoltenImportOutput`) where Molten supports it.
- Preserve unknown metadata.
- Verify with disposable notebooks: text, image and error outputs; save; reopen.

### Controls

The Hydra on `<localleader>j` is the primary surface:

- `j`: run cell and advance (new)
- `l`: run line
- `a`: run above
- `A`: run all
- `r`: re-evaluate
- `o` / `h`: show or hide output
- `x`: open in browser
- `i`: init or select kernel
- `I`: interrupt (new)
- `R`: restart

Direct keys stay for the two hot paths, run cell and interrupt. Remove the global `<leader>q*` duplicates of buffer maps and fold the remaining `<localleader>r`/`m` maps into the Hydra unless they are hot paths.

### Temporary rendering

Add a command that renders the current document with `quarto render` into a temporary directory and opens the result in the browser. The directory sits outside the project, in Neovim's run or temp directory. The command needs no arguments and leaves nothing in the repository. Avoid suggesting broad ignore globs: `*_files/` would hide legitimate `tests/test_files/` directories.

### `PYTHONPATH`

First test whether Molten loads without the workaround on the pinned Nixvim. If it does, delete it. Otherwise build the value without an empty entry or duplicates.

## Risks / Trade-offs

- **[Captured direnv environment goes stale]** → Regenerate the kernelspec when the environment is reloaded or the selection changes, and document restarting the kernel.
- **[Pixi activation needs more than variables]** → Verify with a real Pixi project. Fall back to an explicit, documented limitation rather than running hooks.
- **[Sixel performance and redraw in Zellij]** → Measured acceptable for single plots. Large or many images may be slow, so keep the browser fallback, and never use floating panes for notebooks.
- **[Percent-format outputs are not persisted]** → Intended. Users needing stored outputs export `.ipynb` or render with Quarto explicitly.
- **[Generated kernel names collide across worktrees]** → Include a hash of the absolute root.

## Migration Plan

1. Implement in the shared modules with headless tests: kernelspec generation, missing-`ipykernel` error, `PYTHONPATH` content, mapping table.
2. Build both pinned shared-editor consumers and Kitsune without activation.
3. Repeat the interactive work-laptop checks after the work consumer adopts the revision and sets `sharedEditor.imageBackend = "sixel"`.
4. Roll back by reverting the work consumer's `personal-features` lock.

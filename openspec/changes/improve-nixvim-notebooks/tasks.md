# Tasks

## 1. Investigation (work laptop, 2026-11-16)

- [x] 1.1 Verify Sixel support layer by layer with disposable files: Windows Terminal 1.25 alone, Zellij 0.45.1 normal and floating panes, image.nvim `sixel` backend, Molten through image.nvim; record results in design.md.
- [x] 1.2 Prototype a project kernel via a kernelspec on a temporary `JUPYTER_PATH`; confirm Molten starts it, the kernel reports the project's `sys.executable`, and a matplotlib plot renders inline; record the direnv dependency and the shell-hook side effect of `direnv exec`.

## 2. Hygiene

- [x] 2.1 Test Molten loading without the `PYTHONPATH` workaround on the pinned Nixvim; remove it, or build the value with no empty entry or duplicates. Add a headless check that `PYTHONPATH` has no empty component.
  - Molten never loaded from the build: the Nixvim wrapper's remote-plugin manifest has no Python entries, and Molten only worked through a hand-made `~/.local/share/nvim/rplugin.vim` tied to one store path. The workaround is removed; the module now builds Molten's manifest with `:UpdateRemotePlugins` and points `NVIM_RPLUGIN_MANIFEST` at it before plugins load. `tests/nixvim-molten-host.lua` checks `PYTHONPATH` and that `MoltenInit` and `MoltenAvailableKernels()` exist. The stale user manifest is now ignored and can be deleted.

## 3. Project kernels

- [x] 3.1 Add a kernelspec directory under `stdpath("run")` and put it on `JUPYTER_PATH` before Molten's host starts; verify with a headless check that a spec written after startup is listed by `MoltenAvailableKernels()`.
  - `kit.kernel.setup()` also sets `JUPYTER_RUNTIME_DIR` and creates `<jupyter data dir>/runtime`: Molten writes a copy of each connection file there and fails on a fresh machine where it is missing (reproduced with an empty data directory).
- [x] 3.2 Generate one kernelspec per project root and selected environment (uv `.venv`, Nox, named Pixi) with `argv` on the environment interpreter and `env` from `kit.project_env` (plus Pixi activation variables); include a root hash in the name. Verify with disposable fixtures for two worktrees of one project that each kernel reports its own `sys.executable`.
  - `tests/nixvim-kernel.lua`: distinct names for two worktrees, spec `argv`/`env`/metadata, no writes into the project, and a real kernel start in the sandbox running a cell whose `sys.executable` is the fixture venv's.
- [x] 3.3 Start the generated kernel automatically when unambiguous, use the environment picker otherwise, and show kernel identity after start. Report missing `ipykernel`, unapproved direnv and unavailable environments with the exact preparation command and no fallback to `python3`; verify each case with fixtures and confirm no project files change.
  - `:NotebookKernel`, `:NotebookKernelSelect`, `:NotebookKernelInfo`; `kit.kernel.ensure()` starts a kernel on first use (wired to run-cell in 4.1). Ambiguous means several Pixi environments without a selection; Nox sessions don't count. Molten init failures (reported only as notifications) are detected by checking the buffer's attached kernels. Tested: missing `ipykernel` (`uv add --dev ipykernel` hint), ambiguity, Nox, unapproved direnv (actual message: "direnv export failed; approve the environment or retry: … is blocked").
- [x] 3.4 On the work laptop, verify a real uv worktree project and a real Pixi project start their kernels without re-running shell hooks (no `uv sync` output on kernel start).
  - 2026-11-16: a uv worktree project (kernel in its `.venv/bin/python`, 6-9 s including environment load) and a Pixi project (kernel in `.pixi/envs/default/bin/python`, ~7 s); cells reported those interpreters, and lock files and `.venv` were untouched. Kernel start runs the interpreter directly. Loading the project environment the first time (`direnv export`, shared with LSP) still runs the project's shell hook once per editor session; in the tested uv project that hook runs `uv sync`. Changing that is the project's hook, not the editor.

## 4. Percent-format notebooks

- [x] 4.1 Add `# %%` cell detection for `python` buffers and wire run cell, run-and-advance, run above and run all to Molten. Verify cell boundaries with a headless fixture (first cell, last cell, markdown cells, no cells).
  - `kit.cells`: percent cells in Python buffers, quarto-nvim's runner elsewhere, every action calling `kit.kernel.ensure()` first. `tests/nixvim-cells.lua` covers no markers, header before the first marker, `[markdown]` cells, `#%%` without a space, trailing blanks, an empty last cell, run/advance/above/all ranges and jumping.
- [x] 4.2 Document opening `.ipynb` through Jupytext as import/export and explicit pairing commands; confirm no `.ipynb` is written implicitly when saving a `.py` notebook.
  - `docs/nixvim-notebooks.md`; `tests/nixvim-cells.lua` saves a percent notebook and checks it is the only file written.

## 5. Output and persistence

- [x] 5.1 Set Molten `image_provider = "image.nvim"`; document `sharedEditor.imageBackend` values (`sixel` for Windows Terminal 1.22+ with Zellij, `kitty` for Kitty-protocol terminals) and the floating-pane limitation.
  - Also `image_location = "both"`, so plots sit under their cell with the existing virtual-text output. Documented in the option description and `docs/nixvim-notebooks.md`.
- [x] 5.2 Determine export ordering against Jupytext's write; replace the `pcall` export with a path that reports errors and import stored outputs on open where supported. Verify a disposable `.ipynb` with text, image and error outputs through save and reopen, preserving unknown metadata.
  - Ordering was already right (Jupytext writes cells with `--update`, then fires `BufWritePost`). The real bug: without `!`, `MoltenExportOutput` writes a sibling `copy-of-<name>.ipynb` instead of the notebook, which is where stray `copy-of-*` files and their Quarto renders in work repositories came from. `kit.kernel.export` now writes into the saved file with the buffer's kernel and reports failures; buffers without a kernel are skipped. Molten can only import into a running kernel, so stored outputs load when the kernel starts. `tests/nixvim-ipynb-outputs.lua` runs real cells and checks text, image (`image/png`) and error outputs, notebook metadata, the markdown cell, no `copy-of-*` file, and a warning-free reopen; it fails if the `!` is removed.

## 6. Controls and rendering

- [x] 6.1 Rebuild the notebook Hydra (`j` run-and-advance, `I` interrupt, and the existing actions), keep direct run-cell and interrupt keys, and remove duplicate global and buffer maps; check for collisions and document the menu.
  - The old heads were emitted as strings, which Hydra feeds as keystrokes, so `j`/`l`/`a`/`A` typed `function()…` into the buffer instead of running cells. Heads are now Lua functions (`__raw`), with `c`, `n`/`p`, `d`, `k`, `I` and `e` added. Direct keys: `,rc`, `,mI`, visual `,r`; buffer `,q*`, `,r[aAl]` and `,m*` duplicates removed. No collisions with other `<localleader>` maps (only quarto-sync's `,rp`). `tests/nixvim-cells.lua` drives the Hydra with keys and fails if heads become strings again.
- [x] 6.2 Add a no-argument command that renders the current document with Quarto into a temporary directory outside the project and opens it in the browser; verify nothing is created inside the repository.
  - `:NotebookRender` (`<leader>qr`, replacing in-place `QuartoRender`): `.py` via Jupytext plus the running kernel's outputs and `.ipynb` with stored outputs, both `--no-execute`; `.qmd`/`.md` execute with the project's Python in their own directory. Quarto comes from the project environment (it is not on the default PATH). On WSL the page opens through `wslpath -w`. `tests/nixvim-render.lua` covers all three types, the run-directory location, an unchanged project and a missing Quarto. 2026-11-16 on the work laptop: real Quarto 1.9.37 rendered a percent notebook in 17.5 s with the project unchanged (browser stubbed; opening Windows Firefox is still to check by hand).

## 7. Validation and adoption

- [ ] 7.1 Run the shared consumer checks (stable and work-like) and a non-activating Kitsune build.
  - Done: `shared-stable`, `shared-unstable`, `shared-stable-core`, both `*-editor` checks and `pre-commit-check` pass; Kitsune evaluates without warnings and its Nixvim package and config build. Pending: the full Kitsune system build, which compiles codex from source until `cache.numtide.com` is active on the building machine (added in this branch). `nixvim-neotest-project.lua` failed intermittently twice and passed on rerun; it is an existing test this change does not touch.
- [ ] 7.2 On the work laptop, after the work consumer adopts the revision with `sharedEditor.imageBackend = "sixel"`, repeat the plot, kernel-identity and save/reopen checks in a real project; record sanitized results without copying project contents.
  - Done before adoption, using the work configuration built against this branch: the generated config selects `sixel` and `image.nvim`, and a real uv worktree project started its kernel in 4.2 s with cells running in its `.venv` interpreter. Pending after switching: plots on screen, run-and-advance, save/reopen of a real `.ipynb`, and opening `:NotebookRender` output in Windows Firefox.

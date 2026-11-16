# Tasks

## 1. Investigation (work laptop, 2026-11-16)

- [x] 1.1 Verify Sixel support layer by layer with disposable files: Windows Terminal 1.25 alone, Zellij 0.45.1 normal and floating panes, image.nvim `sixel` backend, Molten through image.nvim; record results in design.md.
- [x] 1.2 Prototype a project kernel via a kernelspec on a temporary `JUPYTER_PATH`; confirm Molten starts it, the kernel reports the project's `sys.executable`, and a matplotlib plot renders inline; record the direnv dependency and the shell-hook side effect of `direnv exec`.

## 2. Hygiene

- [ ] 2.1 Test Molten loading without the `PYTHONPATH` workaround on the pinned Nixvim; remove it, or build the value with no empty entry or duplicates. Add a headless check that `PYTHONPATH` has no empty component.

## 3. Project kernels

- [ ] 3.1 Add a kernelspec directory under `stdpath("run")` and put it on `JUPYTER_PATH` before Molten's host starts; verify with a headless check that a spec written after startup is listed by `MoltenAvailableKernels()`.
- [ ] 3.2 Generate one kernelspec per project root and selected environment (uv `.venv`, Nox, named Pixi) with `argv` on the environment interpreter and `env` from `kit.project_env` (plus Pixi activation variables); include a root hash in the name. Verify with disposable fixtures for two worktrees of one project that each kernel reports its own `sys.executable`.
- [ ] 3.3 Start the generated kernel automatically when unambiguous, use the environment picker otherwise, and show kernel identity after start. Report missing `ipykernel`, unapproved direnv and unavailable environments with the exact preparation command and no fallback to `python3`; verify each case with fixtures and confirm no project files change.
- [ ] 3.4 On the work laptop, verify a real uv worktree project and a real Pixi project start their kernels without re-running shell hooks (no `uv sync` output on kernel start).

## 4. Percent-format notebooks

- [ ] 4.1 Add `# %%` cell detection for `python` buffers and wire run cell, run-and-advance, run above and run all to Molten. Verify cell boundaries with a headless fixture (first cell, last cell, markdown cells, no cells).
- [ ] 4.2 Document opening `.ipynb` through Jupytext as import/export and explicit pairing commands; confirm no `.ipynb` is written implicitly when saving a `.py` notebook.

## 5. Output and persistence

- [ ] 5.1 Set Molten `image_provider = "image.nvim"`; document `sharedEditor.imageBackend` values (`sixel` for Windows Terminal 1.22+ with Zellij, `kitty` for Kitty-protocol terminals) and the floating-pane limitation.
- [ ] 5.2 Determine export ordering against Jupytext's write; replace the `pcall` export with a path that reports errors and import stored outputs on open where supported. Verify a disposable `.ipynb` with text, image and error outputs through save and reopen, preserving unknown metadata.

## 6. Controls and rendering

- [ ] 6.1 Rebuild the notebook Hydra (`j` run-and-advance, `I` interrupt, and the existing actions), keep direct run-cell and interrupt keys, and remove duplicate global and buffer maps; check for collisions and document the menu.
- [ ] 6.2 Add a no-argument command that renders the current document with Quarto into a temporary directory outside the project and opens it in the browser; verify nothing is created inside the repository.

## 7. Validation and adoption

- [ ] 7.1 Run the shared consumer checks (stable and work-like) and a non-activating Kitsune build.
- [ ] 7.2 On the work laptop, after the work consumer adopts the revision with `sharedEditor.imageBackend = "sixel"`, repeat the plot, kernel-identity and save/reopen checks in a real project; record sanitized results without copying project contents.

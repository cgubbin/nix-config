# Notebooks in the shared editor

Notebooks run in the project's own Python environment, show text and plots under
each cell, and render to a temporary page without leaving files in the
repository. Specified by the OpenSpec change `improve-nixvim-notebooks`.

## Formats

- **`.py` with `# %%` cells (primary).** Jupytext's percent format: a line
  starting `# %%` begins a cell, `# %% [markdown]` cells hold prose as comments
  and are not executed, and any text before the first marker is a cell of its
  own. Saving writes only the `.py`; outputs live in the editor session.
- **`.ipynb` (import/export).** Opening an `.ipynb` converts it to a temporary
  Markdown buffer (never a sibling file in the project). Saving writes the cells
  back with `jupytext --update` and then the running kernel's outputs into the
  same file. Use explicit Jupytext commands to pair or convert files, for example
  `jupytext --set-formats ipynb,py:percent notebook.ipynb`; the editor never
  creates a paired file on its own.
- **`.qmd` / `.md`** run through quarto-nvim's code runner.

## Kernels

A notebook's kernel is the project's interpreter, not Neovim's.

- The first run action in a buffer starts the project kernel. `:NotebookKernel`
  starts it explicitly, `:NotebookKernelInfo` shows which interpreter it uses,
  and `:NotebookKernelSelect` chooses the environment first.
- The project is the buffer's root (a Git worktree is its own root). The
  interpreter comes from the selected environment (`:ProjectPythonSelect`), or
  automatically from `.venv` or Pixi. Several Pixi environments with no
  selection is ambiguous, so the editor asks instead of guessing; Nox sessions
  are never notebook targets.
- Kernelspecs are generated under Neovim's run directory and carry the project
  environment captured from `direnv`, so starting a kernel never re-runs direnv
  or project shell hooks. Loading the project environment the first time does
  run the project's hook once per editor session, as it does for language
  servers.
- Nothing is installed or registered. Missing `ipykernel` gives the command to
  add it (`uv add --dev ipykernel`, `pixi add ipykernel`); an unapproved
  `.envrc` asks for `direnv allow`.
- Buffers in the same project share one kernel.

## Controls

`<localleader>j` (`,j`) opens the notebook menu, which stays active until `q` or
`<esc>`:

| Key | Action | Key | Action |
| --- | --- | --- | --- |
| `j` | run cell, move to next | `c` | run cell |
| `l` | run line | `a` / `A` | run cells above / all cells |
| `r` | re-evaluate cell | `n` / `p` | next / previous cell |
| `o` / `h` | open / hide output | `d` | delete cell output |
| `x` | open output in browser | `e` | save outputs to the `.ipynb` |
| `i` | start project kernel | `k` | choose kernel environment |
| `I` | interrupt | `R` | restart kernel |

Direct keys in notebook buffers: `,rc` runs the cell, `,mI` interrupts, and
`,r` in visual mode runs the selection. `<leader>qn` creates a notebook,
`<leader>qr` renders the current document (below), and `<leader>qp`/`<leader>qc`
start and stop Quarto's live preview.

## Plots and images

Molten sends images to image.nvim, which draws them with the consumer's
`sharedEditor.imageBackend`; plots appear under their cell.

- **Windows Terminal 1.22 or later** (including inside Zellij): `"sixel"`.
  Verified with Windows Terminal 1.25 and Zellij 0.45.1.
- **Kitty-protocol terminals** (Kitty, WezTerm without a multiplexer): `"kitty"`.
- Images hide when scrolled off-screen or when windows overlap and return
  afterwards. In Zellij floating panes large images can escape the pane, so use
  normal panes for notebooks.
- When images cannot be shown, `x` in the menu opens the output in the browser,
  and `<leader>qr` renders the whole notebook.

## Rendering

`<leader>qr` (`:NotebookRender`) renders the current file to HTML in a
temporary directory under Neovim's run directory and opens it. Nothing is
written to the repository, so there is no output path to choose and nothing to
keep out of Git.

- `.py` notebooks render what was run: the cells plus the running kernel's
  outputs, without executing again. `.ipynb` files render with their stored
  outputs.
- `.qmd`/`.md` documents execute with the project's Python, in their own
  directory so relative data paths work.
- Quarto comes from the project environment.
- On WSL the page is opened through its Windows path (`\\wsl.localhost\…`).
- Relative links to files next to the source (for example images referenced
  from Markdown) are not copied, so they may be missing from the rendered page.

## Upgrading

Molten is a Python remote plugin. The shared module builds its remote-plugin
manifest with `:UpdateRemotePlugins` and points `NVIM_RPLUGIN_MANIFEST` at it,
so `:UpdateRemotePlugins` is never needed by hand; an old
`~/.local/share/nvim/rplugin.vim` is ignored and can be deleted. The headless
checks in `modules/checks/consumers.nix` start real kernels and exercise save
and reopen; rerun them when updating Molten, Jupytext or Neovim.

# Doom and Org

Import `inputs.personal-features.modules.homeManager.shared-doom-emacs` into a
Linux Home Manager profile. Module selection enables Doom independently of
`shared-editor` (Neovim); remove any overlapping vanilla Emacs selection.
The feature uses the consumer's package set. Set `knowledge.orgDirectory` to an
absolute writable path outside `/nix/store`, for example `/home/kit/notes/work`.
Kitsune uses `/home/kit/notes/personal`. This feature configures no note sync.

`knowledge.enableDaemon` defaults to true. `enableGraphicalIntegration` defaults
to false for consumers and is enabled explicitly on Kitsune. With the daemon
disabled, ordinary Doom editing remains available; launch helpers and shortcuts
are omitted. The feature never changes EDITOR or VISUAL away from Neovim.
Emacs and Zellij use Catppuccin Mocha; the Emacs theme package is built into
the profile through Nix.

## Daemon and quick entry

```sh
org-capture       # template menu in this terminal
org-capture t     # go directly to the TODO template
org-project-capture [file [line]] # capture an engineering note with Git context
org-agenda
org-notes
systemctl --user start emacs
emacsclient -t
emacsclient -t "$HOME/notes/personal/inbox.org"
systemctl --user restart emacs
journalctl --user -u emacs.service -b
```

On consumers with graphical integration disabled (including the work WSL
profile), the three launch helpers start the managed daemon on demand and open
an interactive text frame in the current terminal. Press `q` to leave the
agenda or notes client. Use `C-c C-c` to finish a capture or `C-c C-k` to
cancel; either returns to the shell. Closing a client preserves the daemon.
`emacsclient -c` requests a graphical frame; use `emacsclient -t` for terminal
editing. Restarting the service closes its buffers, so save first. Home Manager
does not restart it automatically on configuration changes.

Inside the managed Zellij configuration, use `Ctrl-b e` for capture, `Ctrl-b a`
for the agenda, or `Ctrl-b r` for Org-roam notes. Each opens in a centered
floating pane; completing capture or pressing `q` closes the pane and returns
focus to the prior layout. Running `org-capture`, `org-agenda`, or `org-notes`
directly from a shell continues to use that terminal inline.

Kitsune enables graphical integration, so its launch helpers continue to use
graphical frames and the desktop bindings below.

Kitsune shortcuts: **Super+Shift+O** opens capture and **Super+Shift+A** opens
the agenda. They are conditional on graphical and daemon integration, and were
checked against the existing bindings. UWSM starts/stops the daemon with
`graphical-session.target`. These shortcuts do not affect Neovim state.

## Work WSL terminal client

Use the same feature with your own `knowledge.orgDirectory` and keep
`knowledge.enableGraphicalIntegration = false`. The daemon and Org workflows
run entirely in the terminal and do not require WSLg, DISPLAY, or
WAYLAND_DISPLAY. The systemd service clears inherited graphical environment
variables in this mode, so stale WSLg values cannot prevent daemon startup.
Run `org-agenda`, `org-capture`, or `org-notes` from the WSL
shell; each command returns to the shell when its client is closed. A graphical
frame is not available in this mode; use `emacsclient -t` for direct editing.

A Windows shortcut can target this command (adjust distribution and username):

```text
wsl.exe -d NixOS -u kit --exec /home/kit/.nix-profile/bin/org-capture t
```

Windows owns shortcut registration. Confirm the executable path on the work
machine (`command -v org-capture`); configurations using per-user system packages
can expose a different path. The separate work repository must explicitly
adopt and pin the feature before this command is available there.

If a client fails, inspect `systemctl --user status emacs` and
`journalctl --user -u emacs.service -b`. Do not run `emacs --daemon` alongside
the systemd service. Windows can launch a WSL terminal command through a
shortcut, but the shortcut itself is managed on Windows.

## Build before activation

From the Doom worktree:

```sh
nix build path:.#doom-emacs --no-link -L
nix build path:.#checks.x86_64-linux.doom-stable-build --no-link -L
nix build path:.#checks.x86_64-linux.doom-unstable-build --no-link -L
nix build path:.#nixosConfigurations.kitsune.config.home-manager.users.kit.home.activationPackage --no-link -L
nix build path:.#nixosConfigurations.kitsune.config.system.build.toplevel --no-link -L
```

No build command activates a generation. Once reviewed and committed, activate
from the intended checkout with `sudo nixos-rebuild switch --flake .#kitsune`.
No activation is performed as part of automated validation.

## Packages and modules

Edit `modules/applications/emacs/doom/init.el` to select Doom modules and their
flags. Declare additional packages in `packages.el`; Unstraightened resolves
Doom recipes and builds their pinned dependencies through Nix. Use its
`programs.doom-emacs.extraPackages` only for additional nixpkgs packages, and
follow upstream override rules for packages already owned by Doom. Do not run
`doom sync`, install packages from inside Emacs or clone another Doom checkout.

Update deliberately with `nix flake update doom-emacs`, review the lock diff,
and rerun both consumer builds. The integration, Doom core, Doom modules and
emacs-overlay are recorded in flake.lock. No separate Emacs flake is needed.

Revert a feature/input change and rebuild to restore its configuration, or
select the previous NixOS generation. Generation rollback does not roll back
your notes. Preserve note backups independently; caches can be rebuilt if a
version change requires it.

See [validation status](emacs-org-validation.md) for actual results and pending
checks. A successful Linux build does not verify WSLg or compositor behaviour.

## Notes, capture and journal

On first Org use, missing destinations are created under your configured root:

```text
inbox.org
agenda/tasks.org
agenda/projects.org
roam/
journal/
```

These are writable user files, never Home Manager symlinks into the store.
Existing files are preserved. Notes are not automatically synchronised. Keep
confidential work material in the work root and choose backups separately.
Org-roam's SQLite database is a local cache in Doom's profile cache directory
(normally `~/.cache/doom/nix/org-roam.db`). Doom also writes profile data/state
under XDG directories; these are distinct from the repository and note contents.

| Capture key | Destination | Purpose |
| --- | --- | --- |
| i | inbox.org | Quick thoughts to process later |
| t | agenda/tasks.org | TODO commitments, visible in the agenda |
| c | roam/ | Scientific concept with stable ID and references section |
| e | roam/ | Engineering investigation: question, evidence, next steps |
| m | journal/meetings.org | Dated meeting entry and actions |
| P | roam/ | Engineering note with repository, branch, commit, and optional file/line |

For concept/investigation captures, enter the title at the initial cursor,
then fill the sections as needed. Use `C-c C-c` to finish and `C-c C-k` to abort.
Actionable entries in inbox.org and agenda/ are included in the agenda; journal
and knowledge files do not compete with it as another task database.

Doom uses Evil movement and a space leader. **SPC n c** captures,
**SPC n a** opens agenda, **SPC n f** finds/creates an Org-roam node, and
**SPC n j** opens today's journal. Which-key shows available commands. In Org,
the local leader is **SPC m**; its **m** submenu contains Org-roam insert, search,
backlinks and daily navigation commands. Use `M-x org-roam-node-insert` to link a
concept and `M-x org-roam-buffer-toggle` for backlinks. Org-roam's own capture
menu also offers physics, derivation, algorithm, paper and experiment templates.
The file IDs make links independent of titles and filenames.

Org-roam's node capture menu also provides project overview (`p`), investigation
(`i`), benchmark (`b`), and architecture decision record (`a`) templates. Use
`org-project-capture path/to/file 42` from a checkout to create a project-context
engineering note with a source link; omit the arguments for repository metadata
only. It records the current checkout's root, branch and commit. This command
does not edit the repository. Keep actionable tasks in `agenda/tasks.org` using
`org-capture t`, then link them to project notes or Linear/GitHub URLs. The
initial workflow intentionally does not enable `org-projectile`: Projectile is
not part of this Doom setup, and project-scoped TODO storage would create a
second task location unless its ownership semantics are specified.

Daily notes use journal/YYYY-MM-DD.org. Open today repeatedly to return to the
same note; use `org-roam-dailies-goto-previous-note` and
`org-roam-dailies-goto-next-note` to navigate. Move or link durable results into
roam/ notes rather than growing an elaborate journal folder tree.

Org links to Linear issues, GitHub PRs and commit permalinks work as ordinary
web links, opened with `C-c C-o`. Keep shared issue/PR state authoritative in
those services. This installation adds no import process, API token or sync.

## Dashboard and scientific notes

New graphical frames show Doom's dashboard, with capture, agenda, knowledge and
journal buttons. The terminal has a text banner and the same menu. Buttons are
also reachable by keyboard; the normal Doom leader bindings continue to work.

Org uses the Nix-managed TeX and dvisvgm tools to preview inline and display
math. In an Org buffer use **SPC m l p** (`org-latex-preview`) to toggle the
preview at point; clear and regenerate it after changing an equation. Use
**SPC m l i** to toggle inline image previews. Keep figures and attached PDFs
as writable files beside a note or in its attachments directory; use relative
`[[file:figures/plot.svg]]` and `[[file:papers/paper.pdf]]` links so exports
remain portable. The configured TeX subset targets previews; PDF export may
require additional TeX packages for the document class and bibliography.

Citar uses `bibliography/references.bib` under each host's Org root and looks
for local papers in `bibliography/papers/`. Existing bibliography data is not
overwritten. Name a paper `CITEKEY.pdf` to associate it with an entry. Insert
with **SPC m i c** (`org-cite-insert`); follow a citation with `C-c C-o` and
choose a local file. Put `#+print_bibliography:` in a document to include its
references on HTML export. Use `org-attach` when a note needs its own files.

Opening or exporting a document does not execute source blocks. Explicit Babel
execution asks for confirmation; review the code before answering. Python,
shell and Emacs Lisp blocks are supported. Select an interpreter for a specific
block with `:python /absolute/path/to/project/.venv/bin/python`; the default
interpreter is not changed. For an already prepared uv project, a block can use
`:python "uv run --offline --no-sync python"`; for an already prepared Pixi
project, use `:python "pixi run --as-is python"` and set the block's `:dir` to
the project directory. These examples use existing environments and do not
install dependencies. Set paths and flags to match the project's own tooling;
only non-session blocks have been checked here. If uv or Pixi are not installed
by your environment, add them through your normal Nix/project setup.

The synthetic example in `docs/examples/scientific/` illustrates a derivation,
a citation, a linked node and a Python-generated SVG. Copy it to a writable
scratch directory, execute the Python block after confirmation, then run
`org-html-export-to-html`; the sample PDF link is illustrative. Engineering
project and ADR templates remain future work.

## Validation and manual checks

```sh
nix build path:.#checks.x86_64-linux.doom-contract --no-link
nix build path:.#checks.x86_64-linux.doom-startup --no-link -L
nix build path:.#checks.x86_64-linux.doom-session --no-link -L
```

`doom-startup` uses a build-sandbox Org root with the same Lisp and package set
as the stable consumer, because its normal `/home/consumer` path is deliberately
unwritable in the sandbox. It tests with fresh HOME/runtime and no network.
`doom-session` boots a disposable VM and exercises actual graphical PGTK frames
under Xvfb and systemd user services. Neither starts your active Emacs service.

After explicitly activating a reviewed generation, check `org-capture t`, save
a task, confirm its frame closes, and run `org-agenda`. Confirm Neovim remains
in its prior buffer and Hyprland returns focus as desired. Open two linked
nodes with `org-notes`, view backlinks, then open today's journal twice. On the
work machine repeat launch after WSL shutdown/start and verify display values
and Windows focus behaviour. These actual-session checks are separate from VM
results and have not been performed by this implementation.

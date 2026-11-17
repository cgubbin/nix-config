# Proposal

## Why

On the work machine, Emacs runs in a terminal frame: a WSL daemon with terminal clients inside
Zellij, in Windows Terminal. A terminal Emacs cannot display images. Figures in Org notes (lab
plots under `roam/<note>/assets/`, manual page renders, org-download images) therefore cannot be
seen at all from Emacs: `org-link-preview` reports "No images to display inline", and `C-c C-o` on
an image link opens the PNG's bytes in a buffer. The same terminal already shows images in nvim
through image.nvim's sixel backend (`sharedEditor.imageBackend = "sixel"`), so it can display
them; Emacs just does not hand them to a program that can. Separately, `SPC m l i` is bound to
`org-toggle-inline-images`, which Org 9.8 deprecates in favour of `org-link-preview`.

## What Changes

- In a **terminal** frame, following a link to an image file (`C-c C-o`, `RET`) opens a Zellij
  pane, tiled rather than floating, because sixel does not work in Zellij floating panes. The pane
  runs a terminal image viewer that uses the same protocol as `sharedEditor.imageBackend` (sixel
  or kitty), and closes when the viewer exits. The Zellij session is the one the calling
  `emacsclient` frame belongs to, read from that client's environment, as the PDF launcher already
  does for its display context.
- Outside Zellij, or when the image cannot be shown, the follow fails with a message naming the
  file instead of opening its bytes.
- In a **graphical** frame, image links behave as they do now.
- `SPC m l i` runs `org-link-preview`. Its description says that a terminal frame cannot preview
  images inline.
- Add the viewer (e.g. `chafa`, which writes both sixel and kitty) to the Emacs module's packages.
- Document how to view images from terminal Org in `docs/emacs-org.md`.

## Capabilities

### New Capabilities
- `org-terminal-image-viewing`: how Org image links are opened from terminal and graphical
  frames, the pane and protocol used, and the fallback when they cannot be shown.

### Modified Capabilities
- None in `openspec/specs/`. The `SPC m l i` binding belongs to `scientific-org` in
  `add-scientific-org-and-dashboard`, which is still unarchived. Note the rebinding there when that
  change is archived.

## Impact

- `modules/applications/emacs/doom/science.el` (or a new module beside it): an image-link follow
  function that checks the frame type, and the `SPC m l i` rebinding.
- `modules/applications/emacs/default.nix`: the viewer package. It reads
  `sharedEditor.imageBackend` where the consumer imports `shared-editor`, and otherwise defaults to
  sixel.
- `tests/doom/`: follow behaviour in terminal and graphical frames, the Zellij command line
  (pane, not floating; correct session; protocol flag), the outside-Zellij fallback, and the
  binding. A real sixel render is a manual host check on the work machine.
- `docs/emacs-org.md`. The notes repository's hub note has a "Viewing figures" step to update once
  this lands.
- Depends on the Zellij setup from `export-zellij-org-workflows` (the work machine imports
  `shared-zellij`).

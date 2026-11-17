# Tasks

## 1. Viewer

- [x] 1.1 Add `modules/applications/emacs/scripts/org-view-image.sh` (design D3): usage
  `org-view-image PROTOCOL FILE`, PROTOCOL one of `sixels`, `kitty`, `symbols`. It rejects a missing
  or unreadable file or an unknown protocol with exit 2 and a message, runs `chafa --format
  PROTOCOL FILE`, prints a close hint and waits for Enter. Package it with `writeShellApplication`
  (`chafa`, `coreutils`) in `default.nix`. Verify with `shellcheck` and a new
  `tests/scripts/org-view-image-test.sh` (mock `chafa` on PATH, like `org-open-pdf-test.sh`):
  argument checks, the `--format` passed through, a path with spaces kept as one argument, and an
  exit after a line on stdin. Run that test from the `doom-startup` check.

## 2. Emacs

- [x] 2.1 In `default.nix`, compute the protocol from
  `lib.attrByPath [ "sharedEditor" "imageBackend" ] "sixel" config` (sixel to `sixels`, kitty to
  `kitty`, ueberzug to `symbols`) and write `kit/org-image-protocol` and the `org-view-image` path
  into `host.el` (design D4). Verify that `doom-stable-build` and `doom-unstable-build` build, and add
  `doom-contract` assertions that a consumer without `shared-editor` evaluates to `sixels` and one
  with `"kitty"` to `kitty`.
- [x] 2.2 Add `kit/org-open-image` and prepend its `org-file-apps` entry after Org loads (design D1,
  D2, D5). Terminal frame: read `ZELLIJ_SESSION_NAME` and `PATH` from the frame's `environment`,
  find `zellij` on that `PATH`, and run `zellij --session S action new-pane --close-on-exit --name
  FILE -- org-view-image PROTOCOL FILE` with `make-process`. Graphical frame: `find-file`. Otherwise
  `user-error` naming the file. Verify with tests in `tests/doom/science.el`, capturing
  `make-process` as the zathura test does:
  - a terminal frame in session `dev` produces exactly that command, with no `--floating`;
  - the session comes from the frame, not the daemon's `getenv`;
  - an image path with spaces is one argument;
  - no session gives a `user-error` containing the file name, with no process and no buffer visiting
    the image;
  - a graphical frame (stubbed `display-graphic-p`) visits the file with no process;
  - a `.txt` link is unaffected;
  - the image entry is first in `org-file-apps`.
- [x] 2.3 Rebind `SPC m l i` to `org-link-preview` with the description from design D6. Verify with a
  test that the Org local-leader map binds `l i` to `org-link-preview`, and that
  `org-toggle-inline-images` is bound nowhere in the config.

## 3. Documentation and host check

- [x] 3.1 Document viewing images from terminal Org in `docs/emacs-org.md`: `C-c C-o` on an image
  link opens a Zellij pane, Enter closes it, the protocol comes from `sharedEditor.imageBackend`,
  the failure outside Zellij, and `SPC m l i` for graphical frames. Replace the "Toggle inline
  images" wording there. Verify that every key and command named in the doc exists in the config.
- [x] 3.2 Manual host check on the work machine after rebuilding with this branch
  (`--override-input personal-features path:<worktree>`) and restarting the daemon. In
  `emacsclient -t` inside Zellij, `C-c C-o` on a PNG link in a notes file opens a tiled pane
  showing the image in sixel, and Enter closes it. Outside Zellij it gives the message. Record
  the outcome in `docs/emacs-science-validation.md`.

## Workflow follow-up

- After merge, update the notes repo's hub ("Subject notes", Lab, step 5) to describe `C-c C-o`
  opening a pane.
- When `add-scientific-org-and-dashboard` is archived, reconcile its `scientific-org` binding
  description with `SPC m l i` running `org-link-preview`.
- Archive this change after 3.2 passes.

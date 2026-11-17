# Design

## Context

- The work machine runs the Emacs daemon with `emacsclient -t` clients inside Zellij 0.45, in
  Windows Terminal. `sharedEditor.imageBackend = "sixel"` (`~/system/config`,
  `modules/users/kit.nix`). That option, defined in `modules/shared/features.nix` (the
  `shared-editor` module), says sixel works inside Zellij but not in Zellij floating panes.
- Following a `file:` link to a PNG uses Org's default `org-file-apps` (`auto-mode`): it visits the
  file, and a terminal frame shows the bytes. `org-link-preview` (Org 9.8.12) cannot preview in a
  terminal frame.
- `server--create-frame` stores each client's environment in the frame's `environment` parameter,
  terminal frames included. That environment carries `ZELLIJ_SESSION_NAME` and the client's `PATH`.
  The daemon's own environment has neither.
- Precedent: `kit/org-zathura-follow` (`science.el`) opens PDFs through a Nix-built launcher
  (`scripts/org-open-pdf.sh`, `writeShellApplication`), passing per-client context. It is tested
  by a shell test (`tests/scripts/org-open-pdf-test.sh`, with a mock viewer) and an Elisp test that
  captures the `make-process` command.
- `science.el:78` binds `SPC m l i` to `org-toggle-inline-images`, which is obsolete since Org 9.8.

## Goals / Non-Goals

**Goals:**
- See linked figures from terminal Emacs without leaving the Zellij session.
- Use the same image protocol nvim already uses on the host.
- Leave graphical frames and non-image links alone.

**Non-Goals:**
- Inline images inside a terminal Emacs buffer: Emacs cannot draw sixel in a buffer.
- Sessions other than Zellij (tmux, a bare terminal). They get the clear failure message.
- Image editing or annotation. PDFs keep the zathura path.

## Decisions

### D1. Hook in through `org-file-apps`, not the `file:` link type
Prepend `("\\.\\(png\\|jpe?g\\|gif\\|svg\\|webp\\)\\'" . kit/org-open-image)` to `org-file-apps`.
Org calls the function with the file and the link; it decides by frame type. In a graphical frame
it does what Org does by default: `find-file`, which displays the image. In a terminal frame it
opens the pane.
*Alternative:* override the `file:` link's `:follow`. Rejected: that function handles every file
link, and `org-file-apps` already exists to dispatch by file type.

### D2. The session and the binaries come from the client, not the daemon
`kit/org-open-image` reads `ZELLIJ_SESSION_NAME` and `PATH` from
`(frame-parameter nil 'environment)`, and finds `zellij` on the client's `PATH`. It runs
`zellij --session <name> action new-pane --close-on-exit --name <file> -- org-view-image <protocol> <file>`
through `make-process` (asynchronous, no buffer). The client's own `zellij` matches its server's
version; a Nix-pinned one could be a different version from the running session.
*Alternative:* add `pkgs.zellij` to `extraBinPackages`. Rejected because of the version mismatch.

### D3. A small Nix-built viewer, `org-view-image`
`scripts/org-view-image.sh` is packaged with `writeShellApplication` (`runtimeInputs = [ chafa
coreutils ]`), like `org-open-pdf`. Usage: `org-view-image PROTOCOL FILE`. It checks that FILE is
a readable image, runs `chafa --format <sixels|kitty|symbols> FILE` sized to the pane, prints a
"press Enter to close" line, and waits on `read`. The pane is opened with `--close-on-exit`, so it
closes when the script ends.
*Alternatives:* `img2sixel`, which is sixel only; `timg`, which needs more dependencies. `chafa`
covers sixel, kitty and character art in one package.

### D4. Protocol comes from `sharedEditor.imageBackend`, defaulting to sixel
In `default.nix`: `backend = lib.attrByPath [ "sharedEditor" "imageBackend" ] "sixel" config;`.
It maps `sixel` to `sixels`, `kitty` to `kitty`, and `ueberzug` to `symbols`, and is written into
`host.el` (next to `org-directory`) as `kit/org-image-protocol`. `attrByPath` means consumers
without `shared-editor` still evaluate.
*Alternative:* a separate `knowledge.imageProtocol` option. Rejected: it would duplicate a setting
the consumer has already made for the same terminal.

### D5. Failure is a `user-error`
In a terminal frame with no `ZELLIJ_SESSION_NAME`, or with no `zellij` on the client's `PATH`,
`kit/org-open-image` signals `user-error "Cannot show image %s in this terminal frame (needs
Zellij)"`. It never falls through to visiting the file.

### D6. `SPC m l i` runs `org-link-preview`
Change the binding in `science.el` and its description to "Preview links (graphical frames)".

## Risks / Trade-offs

- [The client's `PATH` lacks `zellij` (e.g. a stripped environment)] -> D5's failure names the
  problem. The work machine's shells have `zellij` from `shared-zellij`.
- [Sixel in a Zellij pane is sized wrongly or scrolls] -> `chafa` sizes to the pane by default.
  A host check on the work machine confirms the real render; the sandbox cannot.
- [`org-file-apps` is set elsewhere later] -> prepend with `add-to-list` after Org loads, and test
  that the entry is first.
- [The `environment` frame parameter is an Emacs internal] -> it has existed since Emacs 23 and is
  used by `server.el` itself; the test sets it explicitly, so a change would show up there.

## Migration Plan

Rebuild the work config (after `nix flake update personal-features`), then restart the Emacs
daemon. Rollback: rebuild the previous generation. No data is affected.

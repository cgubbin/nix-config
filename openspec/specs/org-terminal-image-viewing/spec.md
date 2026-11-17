# Org Terminal Image Viewing Specification

## Purpose

Lets the user see images linked from Org notes when Emacs runs in a terminal frame, by showing them
in a terminal pane that can draw images, while graphical frames keep Emacs's own image display.

## Requirements

### Requirement: Terminal frames show linked images in a Zellij pane
When the user follows a link to a local image file (PNG, JPEG, GIF, SVG or WebP) from a terminal
frame whose client runs inside Zellij, the image SHALL be shown in a new tiled pane of that client's
Zellij session, not in an Emacs buffer.

#### Scenario: Following a figure link from terminal Emacs
- **WHEN** the user presses `C-c C-o` on `[[file:note/assets/plot.png]]` in a terminal frame whose client was started in Zellij session `dev`
- **THEN** a new tiled pane opens in session `dev` showing `plot.png`, and no buffer visiting `plot.png` is created

#### Scenario: Not a floating pane
- **WHEN** an image pane is opened
- **THEN** it is not floating, because sixel images are not drawn in Zellij floating panes

#### Scenario: Several Emacs clients in different sessions
- **WHEN** two terminal clients of the same Emacs daemon run in Zellij sessions `a` and `b`, and the user follows an image link in the client in `b`
- **THEN** the pane opens in session `b`

### Requirement: The image pane closes on demand
The image pane SHALL stay open, showing the image, until the user dismisses it with a key. Then it
SHALL close.

#### Scenario: Dismissing the image
- **WHEN** the image is shown and the user presses Enter in its pane
- **THEN** the pane closes and focus returns to Zellij's previous pane

### Requirement: The pane uses the terminal's image protocol
The viewer SHALL draw with the protocol configured in `sharedEditor.imageBackend`: sixel for
`"sixel"`, the Kitty graphics protocol for `"kitty"`, and character art for `"ueberzug"`, which a
terminal pane cannot use. When the option is not available, it SHALL use sixel.

#### Scenario: Work machine
- **WHEN** the consumer sets `sharedEditor.imageBackend = "sixel"` and an image is opened
- **THEN** the viewer draws it with sixel

#### Scenario: Consumer without the shared editor
- **WHEN** the consumer does not import the module that defines `sharedEditor.imageBackend`
- **THEN** the configuration evaluates and the viewer draws with sixel

### Requirement: Clear failure when no pane can be opened
When an image link is followed from a terminal frame whose client is not inside Zellij, or when
Zellij cannot be found on the client's path, the follow SHALL fail with a message naming the image
file. It SHALL NOT open a buffer of the file's bytes.

#### Scenario: Terminal client outside Zellij
- **WHEN** the user follows an image link in a terminal frame whose client environment has no Zellij session
- **THEN** a message names the image file and says it cannot be shown in this frame, and no buffer visiting the image is created

### Requirement: Graphical frames and other links are unchanged
Following an image link from a graphical frame SHALL behave as before this change. Following links
to files that are not images SHALL behave as before in every frame.

#### Scenario: Image link in a graphical frame
- **WHEN** the user follows an image link in a graphical frame
- **THEN** Emacs displays the image itself, as it did before, and no Zellij pane is opened

#### Scenario: Non-image link in a terminal frame
- **WHEN** the user follows a link to `notes.txt` in a terminal frame
- **THEN** the file opens in Emacs as before

### Requirement: Inline preview command is current
The Org local-leader binding for previewing images inline SHALL run Org's current preview command,
`org-link-preview`, not the deprecated `org-toggle-inline-images`. Its description SHALL say that
terminal frames cannot preview images inline.

#### Scenario: Using the binding
- **WHEN** the user presses `SPC m l i` in an Org buffer
- **THEN** `org-link-preview` runs, and no obsolescence warning is shown

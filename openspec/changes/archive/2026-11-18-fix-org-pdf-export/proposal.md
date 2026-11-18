# Proposal

## Why

Exporting an ordinary Org note to PDF fails. Org's default LaTeX header loads `fontenc` with T1,
which needs the EC fonts (`ecrm*`). The Nix TeX set (`scheme-basic` plus `lm`, in
`modules/applications/emacs/default.nix`) does not have them, so `pdflatex` stops with "Font
ecrm0800 at 600 not found" and produces no PDF. The maintained scientific example exports only
because it carries its own `#+latex_header: \usepackage{lmodern}`. The `doom-startup` export test
uses that example, so it never sees the failure. Found 2026-11-18 when exporting a learning note
("Maxwell's equations in media") from the notes repository.

A second failure shows up once the font is fixed. Unicode Greek in plain text (ε, χ, ω, which
notes and review logs use) is an error under `pdflatex` ("Unicode character ε (U+03B5) not set
up"). Text inside `\( \)` is unaffected.

PDF is the only way to see a note's mathematics from the terminal Emacs on the work machine, via
zathura or the Zellij image pane. So export has to work for ordinary notes, not only for the
example.

## What Changes

- Make Latin Modern the default font for Org LaTeX export, by adding `lmodern` to
  `org-latex-packages-alist`. The `lm` package is already in the TeX set. Documents that already
  load `lmodern` themselves still export.
- Make plain-text Unicode Greek in exported notes either typeset correctly or fail clearly. The
  design chooses between:
  1. declaring the Greek letters for `pdflatex` (e.g. the `alphabeta` package, or
     `newunicodechar` mappings to math symbols);
  2. switching Org's LaTeX compiler to `lualatex` (already installed), with a Unicode font that has
     Greek (for example Libertinus), which adds `fontspec` and the font to the TeX set;
  3. keeping `pdflatex`, and having notes keep Unicode out of exported text: review and gate
     sections marked `:noexport:` in the notes repository's templates, a convention outside this
     repo.
- Add a regression test that exports a minimal note with **no** LaTeX headers, containing display
  and inline maths and a citation, and checks that a PDF is produced. Add another test for Greek
  in plain text that matches the chosen behaviour.
- Document what a note needs for PDF export in `docs/emacs-org.md`.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `scientific-document-export`: "Declarative PDF export dependencies" now covers any Org document
  that uses the default header, not only "supported" documents that bring their own font set-up.
  It gains a scenario for exporting a note with no LaTeX headers, and a scenario for plain-text
  Unicode Greek.

## Impact

- `modules/applications/emacs/doom/science.el` (or `knowledge.el`, where the LaTeX export
  settings live): `org-latex-packages-alist`, and perhaps `org-latex-compiler`.
- `modules/applications/emacs/default.nix`: the TeX package set, only if option 1 or 2 is chosen.
- `tests/doom/science.el` and the `doom-startup` check: the header-free export test.
- `docs/emacs-org.md`, and `docs/emacs-science-validation.md`, which still says "PDF export is
  not claimed" in one place.
- Option 3 needs a matching change to the notes repository's templates (`:noexport:` on Review
  and Gate); that is outside this repo.

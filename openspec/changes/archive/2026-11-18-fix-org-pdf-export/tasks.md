# Tasks

## 1. Fonts and Greek

- [x] 1.1 Add `newunicodechar` to the TeX set in `default.nix`, and add
  `modules/applications/emacs/doom/kit-unicode.sty` (design D2): the lower-case Greek letters
  mapped to maths symbols (with the ε/ϵ, φ/ϕ, θ/ϑ variants), and the upper-case letters that
  differ from Latin. Verify that `doom-stable-build` and `doom-unstable-build` build, and that a
  minimal document using the package compiles with the profile's `pdflatex`.
- [x] 1.2 In `science.el`, after Org's LaTeX exporter loads, prepend `doom-user-dir` to `TEXINPUTS`
  (keeping the default path) and add `("" "lmodern" t)` and `("" "kit-unicode" t)` to
  `org-latex-packages-alist` (design D1, D2). Verify with the tests in group 2.
- [x] 1.3 Add the `:around` advice on `org-latex--collect-warnings` that names unsupported Unicode
  characters from the compiler output (design D5). Verify with task 2.3.

## 2. Tests

- [x] 2.1 In `tests/doom/science.el`, export a fixture note with no LaTeX headers (inline and display
  maths, a citation of a fixture bibliography key, and prose containing ε and χ(ω)) with
  `org-latex-export-to-pdf`. Check that the PDF exists, and that `pdftotext` shows the Greek letters
  and the resolved citation (design D3). Verify that the check passes in `doom-startup`, and that it
  fails with the `lmodern` entry removed.
- [x] 2.2 Preview a fragment in a note whose prose contains Greek (`org-latex-preview` through the
  existing render helper). Verify that the image is produced without errors.
- [x] 2.3 Export a note whose prose contains an unmapped character (∇). Verify that a PDF is
  produced and that Org's warning reads "PDF file produced with warnings" and names "∇ (U+2207)".
  Verify that the warning disappears when the advice is removed.
- [x] 2.4 Check that the maintained scientific example still exports. The existing test must stay
  green in `doom-startup`.

## 3. Documentation and host check

- [x] 3.1 Document PDF export in `docs/emacs-org.md`: no headers needed, Latin Modern by default,
  Greek letters in prose are mapped, other characters go inside `\( \)` or into `kit-unicode.sty`,
  and review sections are kept out with `:noexport:`. In `docs/emacs-science-validation.md`, replace
  "PDF export is not claimed" with the new results. Verify that every command and file named
  exists.
- [x] 3.2 Host check on the work machine, using the branch through `--override-input`: export
  "Maxwell's equations in media" with `C-c C-e l p`, and check that the PDF opens with its
  equations and citations. Record the result.

## Workflow follow-up

- Notes repository (design D4): `:noexport:` on `* Review` and `* Gate` in the learning templates
  and the existing learning notes.
- Archive after 3.2.

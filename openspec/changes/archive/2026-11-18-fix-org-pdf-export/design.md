# Design

## Context

- Org's default LaTeX header (`org-latex-default-packages-alist`, Org 9.8) loads `fontenc` with
  T1 for `pdflatex`. Without `lmodern`, T1 Computer Modern needs the EC fonts (`ecrm*`), which
  are in neither `scheme-basic` nor anything else in the TeX set in `default.nix`. The `lm` package
  is installed. `lualatex` is installed too; `fontspec`, `unicode-math` and `newunicodechar` are
  not.
- Verified 2026-11-18. Exporting the Maxwell learning note failed only on `ecrm0800`. The same
  generated `.tex` with `\usepackage{lmodern}` added compiled with no errors, apart from four
  plain-text Greek characters (χ, ω, ε): "Unicode character … not set up".
- `org-latex-pdf-process` is set in `knowledge.el` (latexmk). The export test in
  `tests/doom/science.el` exports `docs/examples/scientific/dispersion.org`, which declares
  `#+latex_header: \usepackage{lmodern}` itself, so it never sees the default-header failure.
- The Doom config directory (`doomDir`) is copied whole into the store, and `doom-user-dir` points
  at it at runtime.

## Goals / Non-Goals

**Goals:**
- An ordinary note exports to PDF with Org's default header.
- Unicode Greek in prose is typeset, in exports and in LaTeX previews.
- A regression test that would have caught this.

**Non-Goals:**
- Full Unicode support (arrows, operators, sub- and superscripts, other scripts). Notes write
  maths inside `\( \)`; other characters fail with LaTeX's own message, as documented.
- Switching the LaTeX engine.
- Changing how the scientific example looks.

## Decisions

### D1. Latin Modern by default, through `org-latex-packages-alist`
Add `("" "lmodern" t)`. Org puts it after its default packages, so it works together with
`fontenc` T1, and the trailing `t` includes it in LaTeX previews. A document that also loads
`lmodern` just loads it twice, which is harmless.
*Alternative:* add `cm-super` to the TeX set. Rejected: it is a large Type 1 font package, and
Latin Modern is already installed and is what the example uses.

### D2. Greek through a small `kit-unicode.sty` on `TEXINPUTS`
`modules/applications/emacs/doom/kit-unicode.sty` loads `newunicodechar` and maps each Greek
letter to its maths symbol:
- `\newunicodechar{ε}{\ensuremath{\varepsilon}}`, `ϵ` to `\epsilon`, `φ` to `\varphi`, `ϕ` to
  `\phi`, `θ` to `\theta`, `ϑ` to `\vartheta`, and the rest of α to ω;
- the upper-case letters that differ from Latin: Γ Δ Θ Λ Ξ Π Σ Υ Φ Ψ Ω.
`science.el` prepends `doom-user-dir` to `TEXINPUTS`, with a trailing `:` so the default search
path is kept, and adds `("" "kit-unicode" t)` to `org-latex-packages-alist`. latexmk (export) and
dvisvgm (previews) inherit the environment. Add `newunicodechar` to the TeX set in
`default.nix`.
*Alternatives:*
- Declarations in a class header string. Rejected: `\newunicodechar` must come after its
  package, which Org loads later.
- `\usepackage{<absolute store path>}`. Rejected: LaTeX warns about the name mismatch on every
  run.
- `alphabeta` or `textgreek`. Rejected: they need Greek text fonts (LGR), and maths symbols are
  what the notes mean anyway.

### D3. Regression test with no headers
A fixture `tests/fixtures/plain-note.org`, written into the sandbox, has only `#+title`, inline
and display maths, a citation of a key in a fixture bibliography, and a sentence containing "ε"
and "χ(ω)". The test exports it with `org-latex-export-to-pdf` and checks that the PDF exists. It
then checks with `pdftotext` that the Greek letters and the citation label appear. The existing
example export stays, to cover a document that brings its own `lmodern` (spec scenario).

### D5. Name unsupported characters that Org's warning check misses
Org 9.8.12's `org-latex--collect-warnings` first runs `(re-search-forward "^!\\(.+\\)")`,
excuses a "Unicode character" error, and then looks for its known warnings from that point, which
is already past the error line. The "unicode character(s)" warning therefore never fires, and Org
reports "PDF file produced." Also, `org-latex-remove-logfiles` deletes the `.log`. Found
2026-11-18: called on the compiler output, the function returns nil.
`science.el` adds `:around` advice. When the compiler output contains
`! LaTeX Error: Unicode character X (U+…)`, it adds "unsupported character(s) X (U+…), …" to
whatever Org found, unless Org found an `error`. Org then calls `display-warning` with "PDF file
produced with warnings: …". LaTeX itself decides what is unsupported, so no list has to be kept in
step. If Org fixes the bug, the advice still only adds the character names.
*Alternatives:*
- Scan the note before export. Rejected as the only check, because it would have to guess what
  pdflatex supports.
- `-halt-on-error`. Rejected, because it makes every LaTeX error fatal.
- LuaLaTeX with a Unicode font. A larger change, kept for later.

### D4. Review and gate stay out of exports (notes repository)
The learning-note templates (`templates/{concept,paper,algorithm}.org` in `~/notes/work`) get
`:noexport:` on `* Review` and `* Gate`, and so do the existing learning notes. That is a
notes-repository edit, outside this change. It is recorded here because together with D2 it
resolves the Unicode question: review logs no longer go into PDFs at all.

## Risks / Trade-offs

- [A Unicode character outside the map] -> `latexmk` runs non-stop, so the PDF is still produced
  without the character. D5 makes sure that is reported, naming the character. It is not made fatal
  (owner's choice, 2026-11-18), because `-halt-on-error` would make every LaTeX error fatal. The
  documentation says to use `\( … \)` or add a mapping in `kit-unicode.sty`.
- [Setting `TEXINPUTS` affects every TeX process started from Emacs] -> it only prepends one
  directory holding one uniquely named file, and the trailing `:` keeps the defaults.
- [Prose ε looks different from `\epsilon` in the same note's maths] -> the mapping follows the
  glyph. U+03B5 (ordinary ε) is drawn like `\varepsilon`, and U+03F5 (lunate ϵ) like `\epsilon`. A
  note that wants matching symbols writes `\(\epsilon\)` in its prose.

## Migration Plan

After merge: `nix flake update personal-features` in `~/system/config`, rebuild, restart Emacs.
In the notes repository, add `:noexport:` to the templates and existing notes (D4). Rollback:
rebuild the previous generation.

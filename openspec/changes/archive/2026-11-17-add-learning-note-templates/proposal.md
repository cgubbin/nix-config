# Proposal

## Why

The work notes (`~/notes/work`) are gaining a learning system: subject notes from
integrated-photonics basics to research, written by the owner and reviewed strictly by Claude.
It is planned in that repo as `learning-notes-system`. It needs capture templates for its note
types, and Babel blocks that can run a pixi environment from inside Emacs. Two current problems
also block it:
- the scientific templates `p` (physics concept) and `a` (algorithm) very likely can't be reached,
  because they share keys with `knowledge.el`'s `p` (project overview) and `a` (ADR), which come
  first;
- `pixi` is not in the home profile, so the documented `:python "pixi run --as-is python"` block
  pattern only works inside a project dev shell, which Emacs does not see.

## What Changes

- Add a **learning** group of org-roam capture templates, under the `l` key prefix: concept stub,
  paper, algorithm, map of content, architecture. Each produces
  `<timestamp>-<type>-${slug}.org` with the matching filetag. The body is read at capture time
  from `templates/<type>.org` in the notes repo, like the `f`/`F` process templates this branch is
  stacked on, so layouts can change without a rebuild.
- **Replace the overlapping templates**, which also fixes the key collision. The learning templates
  take over from the ones that make the same kind of note under the same tag: `knowledge.el`'s `c`
  (scientific concept, tag `concept`, in both `org-roam-capture-templates` and
  `org-capture-templates`), and `science.el`'s `p` (physics concept), `a` (algorithm,
  tag `algorithm`) and `r` (paper, tag `paper`). `p` and `a` can't be reached today anyway. The
  remaining templates keep their keys: `d`, `e`, `p` (project), `i`, `b`, `a` (ADR), `m`
  (derivation), `x` (experiment). **BREAKING**: `c` and `r` are removed. Use `lc` and `lp`.
- Add a test that checks **which** template a key runs, not only that a note was created, and that
  no two org-roam capture templates share a key.
- Put **pixi** on the home profile's PATH, wrapped so that conda-forge binaries run on NixOS, so
  Babel blocks can use `pixi run --as-is` from Emacs.
- Document the learning templates and the pixi block pattern in `docs/emacs-org.md`.

## Capabilities

### New Capabilities
- `learning-note-capture`: the learning templates, their keys, filenames, tags and where their
  bodies come from, and
  the rule that every org-roam capture key is unique.
- `babel-pixi-runtime`: pixi available to Emacs, so Babel blocks can run in a pixi workspace from
  any org file.

### Modified Capabilities
- None in `openspec/specs/`. `scientific-org` belongs to `add-scientific-org-and-dashboard`, which
  is implemented and not yet archived. Its requirement "Scientific note templates" (physics
  concepts, derivations, algorithms, papers, experiments) still holds: concepts, algorithms and
  papers are now provided by the learning templates. When that change is archived, check that its
  scenario wording still matches.

## Impact

- `modules/applications/emacs/doom/`: a new `learning.el` loaded from `config.el`. The `p`, `a` and
  `r` templates are removed from `science.el`, and `c` from `knowledge.el`.
- `modules/applications/emacs/default.nix` (or the home module that owns packages): wrapped
  `pixi` in the home profile.
- `tests/doom/science.el` (only `m` and `x` stay there; the template identity check is added) and a
  new `tests/doom/learning.el`,
  both run by the `doom-startup` check.
- `docs/emacs-org.md`.
- Consumer: `~/notes/work`'s `learning-notes-system` depends on this change. No notes files change
  here.

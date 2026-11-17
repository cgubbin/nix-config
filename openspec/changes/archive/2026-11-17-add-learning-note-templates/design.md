# Design

## Context

- `org-directory` is `~/notes/work`, and org-roam's directory is `~/notes/work/roam/`. The learning
  system and its note types are defined in that repo's `learning-notes-system` change. This change
  is the Emacs/Nix side.
- `knowledge.el:224` sets `org-roam-capture-templates` to `d c e p i b a`. `science.el:91-97` then
  appends `p m a r x`. The first match wins, so `science.el`'s `p` and `a` very likely can't be
  reached. `tests/doom/science.el:271` captures with `p` and `a` but checks only that a note was
  created, so it can't see the problem.
- `knowledge.el` also defines `c` "Scientific concept" in `org-capture-templates`, writing
  `:concept:` notes through `kit/org-new-node-file`.
- Babel: `org-confirm-babel-evaluate t`, no evaluation on export. `docs/emacs-org.md:244` documents
  `:python "pixi run --as-is python"` with `:dir` for non-session blocks. pixi exists only in the
  `doom-startup` check's inputs, not in the home profile.
- The work flakes (`~/code/flakes/notebook_env`, `meep-optimiser`) wrap pixi with `buildFHSEnv`
  because conda-forge binaries expect a standard Linux filesystem layout.
- Tests: `modules/checks/doom.nix` `doom-startup` runs `tests/doom/startup.el`, which loads
  `knowledge.el`, `projects.el` and `science.el`.

## Goals / Non-Goals

**Goals:**
- One template per note type, so that a tag means one layout.
- Capture keys that can't collide without a test failing.
- Babel blocks run in a pixi workspace from the normal Emacs session.

**Non-Goals:**
- Notes content, hub notes or the lab workspace itself. Those belong to `~/notes/work`.
- The "Fab process review" template (`f`) that `process-data.org` refers to. It isn't defined in
  this repo. That is a separate question for the owner.
- Babel sessions in pixi workspaces. Only non-session blocks are supported, as now.

## Decisions

### D1. Learning templates live in `learning.el` under the `l` prefix
`("l" "Learning")` is a group entry, followed by `lc` concept, `lp` paper, `lg` algorithm, `lm` map
of content, `la` architecture. They're defined in a new `doom/learning.el`, loaded from
`config.el` after `science.el`, and appended to `org-roam-capture-templates` the way `science.el`
appends its own.
*Alternatives:* adding them to `science.el`, which mixes general scientific writing with one
learning workflow; or single-letter keys, which are almost all taken.

### D2. Replace, don't rekey, the overlapping templates
`knowledge.el`'s `c` (in both template lists) and `science.el`'s `p`, `a` and `r` are removed.
The learning templates replace them, so `concept`, `paper` and `algorithm` each have one template.
`m` (derivation) and `x` (experiment) stay.
*Alternative:* move the scientific templates under an `s` prefix and keep them all. Rejected:
that leaves two templates writing `concept`, `paper` and `algorithm` notes with different
layouts, and breaks `m`, `r` and `x` muscle memory for no gain.

### D3. Bodies are files in the notes repo; Emacs owns keys, filenames and tags
Each learning template is `plain (function …)`. The function reads
`<org-directory>/templates/<type>.org` at capture time and raises a `user-error` naming the file
if it is missing. Org's `(file …)` template type was not used, because when the file is missing
it creates the note anyway with a "Template file … not found" heading. Target is
`%<%Y%m%d%H%M%S>-<type>-${slug}.org` and head `#+title: ${title}\n#+filetags: :<type>:\n`. This
follows the `f`/`F` process templates on `feat/org-roam-platform-template`, which this branch is
stacked on. Unlike those, the path is built from `org-directory`, not hard-coded, so the sandbox
check can supply fixture files. The bodies (properties, headings, gate) are owned and tested by
`learning-notes-system` in `~/notes/work`, and can change there without a rebuild.
*Alternative:* inline bodies in `learning.el`. Rejected, because every layout change would need a
rebuild and a switch while the conventions are still settling.

### D4. Key uniqueness is tested
A new test walks `org-roam-capture-templates`, collects the full key of every non-group entry, and
fails, naming the key, if any appears twice. It also asserts that no non-group key is a prefix of
another key. A second test captures with each key and checks one thing that marks that template
(filetag, plus one heading), so a shadowed template fails.

### D5. pixi from the home profile, FHS-wrapped
`home.packages` gets `pkgs.buildFHSEnv { name = "pixi"; runScript = "pixi"; targetPkgs = p: [ p.pixi ]; }`,
the same wrapper the work flakes use. It's added in the Emacs module, because Babel is its
consumer, and it does not depend on `enableDaemon` (`default.nix:153` currently adds packages only
when the daemon is enabled).
*Alternatives:* plain `pkgs.pixi`, whose conda-forge python can't find a dynamic loader without
nix-ld, and nix-ld isn't configured in this repo; or per-project flakes with direnv, which Emacs
doesn't see.

## Risks / Trade-offs

- [Removing `c` and `r` breaks habits] -> `docs/emacs-org.md` gives the old-to-new key table.
  Existing notes made with them are unchanged.
- [The FHS wrapper adds a few seconds to each block's start] -> Acceptable for occasional mode
  solves. Sessions are a non-goal.
- [The `doom-startup` sandbox can't download conda packages] -> The pixi Babel test uses a
  dependency-free pixi workspace, as `docs/emacs-science-validation.md` already does. A real
  conda-forge run is a manual check on the host, listed in the tasks.
- [`add-scientific-org-and-dashboard` is unarchived and its scenarios mention the removed
  templates] -> Recorded in the proposal: reconcile when it is archived.

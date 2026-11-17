# Tasks

## 1. Key collision and uniqueness test

- [x] 1.1 Add a key-uniqueness test to `tests/doom/knowledge.el`, which `tests/doom/startup.el`
  already loads after all modules. It collects every non-group key in `org-roam-capture-templates`,
  and fails on a duplicate (naming it) or on a key that is a prefix of another. Verify that it fails
  on the current config (`p` and `a` duplicated) by running `nix build .#checks.x86_64-linux.doom-startup`.
- [x] 1.2 Remove `p` (physics concept), `a` (algorithm) and `r` (paper) from `science.el`, and `c`
  from both template lists in `knowledge.el`. Update `tests/doom/science.el` to exercise only `m`
  and `x`, and change its `("d" "c" "e")` assertion to `("d" "e")`. Verify that the 1.1 test now
  passes in `doom-startup`.

## 2. Learning templates

- [x] 2.1 Create `modules/applications/emacs/doom/learning.el` with the `l` group and `lc`, `lp`,
  `lg`, `lm` and `la`, following design D1 and D3: bodies read from
  `<org-directory>/templates/<type>.org`. Load it from `config.el` after `science.el`. Verify that
  `doom-startup` builds and the 1.1 test passes.
- [x] 2.2 Add `tests/doom/learning.el`, loaded from `startup.el`. It writes fixture
  `templates/<type>.org` files into the sandbox org directory, and for each learning key captures a
  note through `org-roam-capture-`. Check that the filename matches `<timestamp>-<type>-<slug>.org`,
  that the filetag is right, and that the body is the fixture's. Then change one fixture and capture
  again: the new body appears with no reload. Finally, with one fixture removed, capture fails and
  no note is created. Verify that the test passes in `doom-startup`.
- [x] 2.3 Add a template-identity check: capture with every org-roam key and assert each note's
  filetag matches the one expected for that key (e.g. `a` gives `adr`, `lg` gives `algorithm`).
  Also check that no template other than the learning ones sets `concept`, `paper` or
  `algorithm`. Verify that it passes, and that temporarily re-adding a duplicate `a` makes it fail.
- [x] 2.4 Update the scientific example in `docs/examples/scientific/` if it refers to the removed
  templates. Verify that `doom-startup`'s export test still passes.

## 3. pixi for Babel

- [x] 3.1 Add the FHS-wrapped `pixi` (design D5) to the Emacs module's packages, independent of
  `enableDaemon`. Verify that `doom-stable-build` and `doom-unstable-build` build and that
  `bin/pixi` is in the profile.
- [x] 3.2 Add a Babel test to `tests/doom/learning.el` using a dependency-free pixi workspace, as
  in `docs/emacs-science-validation.md`. A confirmed block with `:python "pixi run --as-is python"`
  and `:dir` returns its result, and an uninstalled workspace fails without downloading anything.
  Verify that it passes in `doom-startup`.
- [x] 3.3 Manual host check after `home-manager switch`: from the Emacs daemon,
  `(executable-find "pixi")` returns a path, and a block in a real conda-forge workspace
  (`~/notes/work/lab` once it exists, or a scratch workspace with `python`) prints a result.
  Record the outcome in `docs/emacs-science-validation.md`.

## 4. Documentation

- [x] 4.1 Document the learning templates in `docs/emacs-org.md`: the `l` group and its keys, what
  each produces, the old-to-new key table (`c` becomes `lc`, `r` becomes `lp`, and the scientific
  `p`/`a` are replaced by `lc`/`lg`), and the header-args line for running a note's blocks in a pixi
  workspace. Verify that every key in the doc exists in the config and every learning key is in
  the doc.

## Workflow follow-up

- Apply and switch before applying `learning-notes-system` group 2 in `~/notes/work`.
- When `add-scientific-org-and-dashboard` is archived, reconcile its scientific-org scenarios with
  the removed templates.
- Archive this change after the host check (3.3) passes.

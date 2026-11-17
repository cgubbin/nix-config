# Scientific Org and dashboard validation

The uncommitted foundation and initial dashboard/science draft were reviewed in
the `explore/doom-org` worktree. The foundation's prior checks are recorded in
`emacs-org-validation.md`. The initial draft command
`nix build path:.#checks.x86_64-linux.doom-startup --no-link` failed during
evaluation because this pinned package set has no top-level `pkgs.dvisvgm`.
No pre-existing work was discarded or activated.

Read-only evaluation of both locked package sets found `texlive.withPackages`,
`texlive.bin.dvisvgm`, and the required `texlive.pkgs` components on each.

The minimal TeX environment uses `texlive.withPackages` with the basic scheme,
LaTeX, AMS, graphics, ulem, dvips and dvisvgm components. The stable consumer's
TeX environment has a 770 MiB transitive closure (`nix path-info -Sh`); this is
not the incremental disk cost if dependencies are already present. Real inline
and display SVG previews and regeneration passed in the isolated startup check.
PDF export is not claimed: document classes and bibliography processors can
require additional TeX packages.

The startup check runs with an isolated HOME and Nix build sandbox. It verifies
that opening and HTML export do not execute Python, shell or Emacs Lisp blocks;
that execution prompts and refusal prevents the side effect; that explicitly
confirmed execution works; and that distinct interpreter wrappers, uv, and a
dependency-free Pixi workspace run without downloading dependencies. Only
non-session blocks were checked. It also creates all five new roam templates,
resolves synthetic citations, executes the example figure block with explicit
confirmation, and exports the example HTML without rerunning it.

The disposable NixOS VM runs PGTK under Xvfb. It verifies a dashboard on a new
graphical frame and its actions, capture finalise/abort and independent daemon
lifecycle. A terminal startup check verifies the text dashboard. These checks do
not establish focus behaviour in an actual Hyprland session, or WSLg startup,
restart and Windows focus behaviour; those require manual verification after a
separate activation/adoption decision. The work host has not been changed.

Final validation (no activation):

```sh
nixfmt --check modules/applications/emacs/default.nix modules/checks/doom.nix modules/checks/doom-session.nix modules/hosts/kitsune/home.nix flake.nix
shellcheck modules/applications/emacs/scripts/org-client.sh
openspec validate add-scientific-org-and-dashboard --strict
nix flake check path:. --no-build
nix build path:.#checks.x86_64-linux.pre-commit-check path:.#checks.x86_64-linux.kitsune-config path:.#checks.x86_64-linux.doom-contract path:.#checks.x86_64-linux.doom-startup path:.#checks.x86_64-linux.doom-stable-build path:.#checks.x86_64-linux.doom-unstable-build path:.#checks.x86_64-linux.doom-session path:.#nixosConfigurations.kitsune.config.system.build.toplevel --no-link -L
nix build path:.#checks.x86_64-linux.doom-startup --no-link -L
```

All commands succeeded; the startup check was rerun after expanding citation and
example-equation coverage. The VM also displayed an inline SVG. `nix flake
check` emitted an existing nixfmt alias warning. Existing lock nodes were
compared against the baseline and are unchanged; Doom and its input nodes were
added. No Nixvim files were changed in this worktree, and test note content is
synthetic. Real notes and secrets are outside the store-managed configuration.

After review and commit, use `sudo nixos-rebuild switch --flake .#kitsune` from
the intended checkout only when ready to activate. Then run `org-capture t`,
finish with `C-c C-c`, check that focus returns to the previous application,
run `org-agenda`, and use `emacsclient -c` to inspect the dashboard. For WSLg,
adopt the shared feature in the separate work repository, then after a WSL
restart run `org-capture t` from the WSL shell and inspect `systemctl --user
status emacs` and `journalctl --user -u emacs.service -b` if it fails.

## Learning templates and Pixi in Babel (add-learning-note-templates)

Correction to the startup check above: until this change, its uv/Pixi Babel
assertion matched the marker in the block's own source, so it passed without the
block running. Plain `pixi` could not run there: Pixi's activation script calls
`/usr/bin/env`, which the build sandbox lacks. The check now asserts the
`#+RESULTS:` line and uses the FHS-wrapped `pixi` the profile ships. Both the uv
and Pixi blocks are now shown to run. A mutation (marker in the source, no
output) makes the check fail.

Sandbox checks (`doom-startup`, `doom-contract`, `pre-commit-check`, stable and
unstable builds, `kitsune-config`) cover: capture-key uniqueness (it failed on
the previous config, which had `p` and `a` duplicated), the identity of every
key's template, the learning templates' filenames, tags and bodies read at
capture time, and an error when a template file is missing. They also run a
Babel block in an installed dependency-free Pixi workspace via
`pixi run --as-is`, and check that an uninstalled workspace fails without
installing anything.

Host check, work WSL, 2026-11-17: the work configuration built with
`--override-input personal-features path:<this worktree>`, with its lock file
unchanged, and was switched to. In Emacs, `(executable-find "pixi")` returned
`/home/kit/.nix-profile/bin/pixi`. In a conda-forge workspace (`pixi init`,
`pixi add python numpy`), a confirmed block with
`:python "pixi run --as-is python"` and `:dir` set to the workspace printed
`/tmp/em_test/.pixi/envs/default/bin/python 2.5.5`: the workspace's own
interpreter and numpy. The learning capture keys were not exercised on the host,
because the notes repository's template files do not exist yet.

Follow-up, 2026-11-17: a property drawer in a template body landed after
`#+title`, which Org does not treat as file-level, so Org-roam read no
`ROAM_REFS`. This was found by capturing into a scratch directory in the work
Emacs. Neither a drawer in the body nor an org-capture `%(...)` expression can
reach the note's top drawer: `%(...)` runs before the target buffer exists. The
capture now moves a leading drawer into the note's top drawer through
`org-roam-capture-new-node-hook`. `doom-startup` checks that the reference
resolves, that `STATUS` is file-level with a single drawer, and that the next
non-learning capture does not inherit the properties. A mutation without the
hook fails on the reference.

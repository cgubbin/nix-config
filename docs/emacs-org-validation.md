# Doom / Org validation

Base: migration commit `63166a5`. The isolated Doom worktree was rebased onto
that commit; the original refactor checkout was not modified.

Integration paths: `modules/applications/emacs/default.nix` registers
`modules.homeManager.shared-doom-emacs`; Kitsune composition is
`modules/hosts/kitsune/home.nix`. Its old vanilla import is in
`modules/applications/default.nix`. Neovim remains `shared-editor`.
Baseline evaluated Nixvim init source: `/nix/store/dksanamd7ymp7w03ncs6jcdp2wfbspxc-init.lua`.

Session ownership: pinned Home Manager services.emacs supports
startWithUserSession = "graphical" and binds to graphical-session.target,
matching Kitsune's UWSM/SwayNC lifecycle. WSL consumers use false for on-demand
start. Consumer fixtures live in `modules/checks/consumers.nix`.

Unstraightened pin: `c583b2832cd2505b1de533754da6aa2d64c7825e`.
Doom core: `7ccac7f643ad67baa25b216717cf8617a0903c69`.
Doom modules: `f054be8fcdd2a0446eb8259d76dd4f6f76acc0b7`.
Source options and services.emacs integration were inspected at these pins.
Actual Hyprland and WSLg sessions have not been tested. Graphical testing below
uses PGTK frames under Xvfb inside a disposable VM.

## Milestone 1

Passed: minimal Doom package build; stable and work-like unstable Home Manager
activation-package builds; Kitsune Home Manager activation-package build;
consumer option evaluation; feature-selection/path-type contract check; and
fresh-state daemon startup in a network-isolated Nix sandbox loading the Doom
profile, Evil, Which-key and Org. The startup test caught Doom's lazy Org
defaults disabling Babel confirmation; configuration now sets it after Org
loads and the check passes. No live service was started.

Kitsune's evaluated Nixvim init source is identical to the baseline. All existing
non-root lock nodes compare equal to the pre-change lock; only Doom inputs and
the root dependency mapping were added. Commands are in docs/emacs-org.md.

## Milestone 2

Passed the disposable `checks.x86_64-linux.doom-session` NixOS VM test with
Xvfb-backed graphical PGTK frames: concurrent managed starts reuse the same
daemon; ordinary client frames/file opening work; capture finalisation saves
and closes only its frame; cancellation preserves ordinary frames; closing
all frames keeps the service alive; an independent restart completes within
15 seconds; stale manager display values are replaced; missing graphics,
startup failure and socket-readiness timeout produce bounded diagnostic errors;
and quotes/newlines in a template argument cannot inject Lisp.

The VM initially exposed a first-shutdown bookmark-directory prompt. Creating
Doom's writable profile data/cache/state directories at startup fixed clean
restart; no shutdown timeout was shortened and no save hooks were disabled.

Generated Kitsune unit uses the final Doom package, RuntimeDirectory=emacs,
Type=notify and graphical-session.target for After/PartOf/WantedBy. Its two
new bindings are Super+Shift+O and Super+Shift+A with packaged executable paths.
The daemon-disabled consumer builds omit services and Org helper packages.
Actual Hyprland focus return, Wayland rendering, Windows shortcut behaviour
and WSLg shutdown/restart cycles remain unverified.

## Milestone 3 subset

Passed the network-isolated startup/knowledge test using a sandbox-local
configured root with the same Lisp and dependency set. Checks cover preserving
existing notes during repeated layout setup; separate scratch roots; all five
capture templates; TODO agenda inclusion; Org-roam node lookup, stable IDs,
links and backlinks; backlinks-buffer creation; daily-note creation/save/reuse;
a writable local SQLite cache; and no source-block execution on document open.
The node-picker launcher also passed in the VM, alongside agenda and capture.

New daily notes follow standard Org-roam editing: the buffer is created and
the user saves it normally. Reopening the saved date reuses the file. Full
scientific export/toolchains and engineering project/ADR templates remain
follow-up scope, as do adoption and real runtime tests in the work repository.

## Final integration results

All selected checks passed on 2026-11-09:

- `nix flake check path:. --no-build` (after materialising Doom's IFD outputs).
- `nix build path:.#checks.x86_64-linux.pre-commit-check --no-link`: deadnix and statix.
- `nix build path:.#checks.x86_64-linux.kitsune-config --no-link`.
- `nix build path:.#checks.x86_64-linux.doom-contract --no-link`.
- `nix build path:.#checks.x86_64-linux.doom-startup --no-link`.
- `nix build path:.#checks.x86_64-linux.doom-stable-build --no-link`.
- `nix build path:.#checks.x86_64-linux.doom-unstable-build --no-link`.
- `nix build path:.#checks.x86_64-linux.doom-session --no-link` (44-second final VM run).
- `nix build path:.#nixosConfigurations.kitsune.config.system.build.toplevel --no-link`.
- `nixfmt --check` on changed Nix files, ShellCheck on the launch script and
  `git diff --check`.

Built system: `/nix/store/6fz864yqzyg51w043vrapabqgp0ivljb-nixos-system-kitsune-26.05.20261105.c56a87d`.
Kitsune Nixvim's final init source still matches the migration baseline exactly.
Existing lock nodes remain unchanged. The main checkout and separate work repo
were not modified, and no active generation or live user service was changed.

The lint source needed `lib.cleanSource` to exclude a linked worktree's `.git`
pointer; this lets the existing git-hooks check initialise its sandbox repo.
The initial concurrent flake evaluation hit an unavailable IFD derivation;
sequential evaluation after the package builds passed. Existing shared-feature
FZF/Atuin and package-renaming warnings remain outside this change. The media
VM check was evaluated by flake check, not rerun because its implementation is
unaffected.

## File inventory and deferred work

- `flake.nix`, `flake.lock`: Unstraightened input and locked Doom dependencies.
- `modules/applications/emacs/default.nix`: public feature, options, packaged
  commands, daemon and conditional desktop integration.
- `modules/applications/emacs/doom/{init,config,packages,entrypoints,knowledge}.el`:
  module selection, runtime configuration, external frames and Org workflows.
- `modules/applications/emacs/scripts/org-client.sh`: shared launcher body.
- `modules/applications/default.nix`, `modules/hosts/kitsune/home.nix`: replace
  selected vanilla Emacs with Doom and set the personal root.
- `modules/checks/doom.nix`, `modules/checks/doom-session.nix`, `tests/doom/`:
  stable/unstable fixtures, contracts, offline knowledge and graphical VM tests.
- `modules/maintenance.nix`: worktree-safe lint source filtering.
- `docs/emacs-org.md`, this report and `docs/shared-features.md`: user and
  consumer documentation; OpenSpec change artifacts track the implementation.

Milestones 1 and 2 and the planned minimal Milestone 3 subset are implemented.
Real host graphical acceptance and work-repository adoption are follow-ups.
Milestone 4 (scientific tools/export/citations) and Milestone 5 (project/ADR
templates and repository-aware capture) remain separate changes. Linear/GitHub
API synchronisation, including generated agenda imports, is not implemented.

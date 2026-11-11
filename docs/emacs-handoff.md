# Emacs handoff

This handoff accompanies the declarative Doom/Org feature and the completed
OpenSpec changes `add-declarative-doom-org` and
`add-scientific-org-and-dashboard`. The feature is merged into the personal
configuration's `main` and has been build- and VM-checked without activating a
system generation.

## Ready to try on Kitsune

The Kitsune Home Manager profile enables the shared feature with notes rooted
at `/home/kit/notes/personal`. Rebuild from an updated checkout only when
ready:

```sh
sudo nixos-rebuild switch --flake .#kitsune
systemctl --user status emacs
org-capture t
org-agenda
emacsclient -c
```

Check that capture returns focus to the prior application and that the
dashboard opens on a fresh graphical frame. The Xvfb VM tested frame creation,
dashboard actions, capture completion/cancellation, daemon restart and an
inline image; it cannot verify real Hyprland focus behavior.

## Work WSL adoption and validation

The Work NixOS-on-WSL configuration is a separate consumer. Its notes must stay
under a private root such as `/home/kit/notes/work`; do not sync that directory
to personal devices. Import the exported Home Manager feature and set its
consumer options:

```nix
{ inputs, ... }:
{
  imports = [ inputs.personal-features.modules.homeManager.shared-doom-emacs ];
  knowledge.orgDirectory = "/home/kit/notes/work";
  knowledge.enableDaemon = true;
  knowledge.enableGraphicalIntegration = false;
}
```

The terminal-only daemon clears stale display variables and does not need WSLg.
Keep the personal `shared-zellij` export only if the Work profile should
replace its complete Zellij configuration; it supplies `Ctrl-b P` project TODO
capture and `Ctrl-b A` project agenda bindings. Remove overlapping local
Zellij configuration first. Linked worktrees created from a bare Git
repository share a project task file within this Work Org root.

For a local trial, point the Work repository's existing feature input at this
checkout. For the long-term reproducible consumer, update that input to the
reviewed producer Git revision and lock it. Regenerate the generated flake,
then build before activating:

```sh
nix run .#write-flake
nix flake lock --update-input personal-features
nix build .#nixosConfigurations.work.config.system.build.toplevel --no-link -L
```

Review and commit the input and lockfile changes in the Work repository. Then
activate with its documented NixOS-on-WSL command. From a bare worktree or
ordinary checkout, test `org-project-todo`, `org-project-agenda`, `org-capture
t`, `org-agenda` and `emacsclient -t`. Confirm a project task appears in the
global agenda and that shell exit returns after closing the Zellij floating
pane. For graphical integration, intentionally enable it and test WSLg
separately. WSL shutdown/restart and real WSLg frame/focus behavior have not
been tested here.

## Remaining roadmap

- Build and try the updated feature in the separate Work repository. Confirm
  that work notes use their own root and remain unsynchronized.
- On Kitsune, test real Hyprland capture/agenda shortcuts and Zellij floating
  panes after an explicit generation activation.
- Expand project and ADR note templates or add optional repository-aware
  engineering capture if those workflows need more structure.
- Design Linear/GitHub imports separately. Keep Linear authoritative for issue
  state, GitHub authoritative for PR/CI state, and Org authoritative for
  personal notes. Any write-back needs explicit conflict and ownership rules.

## Validation already completed

The Doom change passed strict OpenSpec validation, formatting/lint checks,
flake evaluation, stable and unstable consumer builds, the Kitsune system
closure build, isolated Org/Babel/Citar/TeX tests, and the disposable graphical
session VM. No generation was activated. See
[`emacs-science-validation.md`](emacs-science-validation.md) and
[`emacs-org-validation.md`](emacs-org-validation.md) for details.

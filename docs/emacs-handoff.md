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

The separate repository is `/home/kit/Repos/wsl-nix-config`. The consumer
import is pushed on branch `feature/doom-emacs-consumer` at commit `287e505`.
It uses the personal configuration's pinned Doom commit `fe866d6`, sets the
work-only root to `/home/kit/notes/work`, enables the daemon and leaves
graphical integration disabled. Do not sync this tree to personal devices.

The work config branch is ready to try, but it has not been built or activated.
At work, check out that branch. Convert its local `workbench` input to the Git
URL you use there, regenerate the generated flake, and create the lockfile:

```sh
git fetch origin feature/doom-emacs-consumer
git switch feature/doom-emacs-consumer
nix run .#write-flake
nix flake lock
nix build .#nixosConfigurations.work.config.system.build.toplevel --no-link -L
```

Review and commit the workbench URL and lockfile updates in the work repository.
Then activate using that repository's documented NixOS-on-WSL command. After a
WSL shutdown/start, test
`org-capture t`, `org-agenda`, `emacsclient -c`, `systemctl --user status emacs`
and the user journal. Check WSLg environment refresh and Windows focus return.
These real WSLg checks have not yet been performed.

## Remaining roadmap

- Complete the work repository import and build/activation checks described
  above. Confirm that work notes use their own root and remain unsynchronized.
- Optionally add and test a PDF export toolchain. Current TeX dependencies
  provide equation previews; the full document-class and bibliography toolchain
  is not claimed.
- Propose a separate OpenSpec change for engineering project notes, ADR
  templates, and optional repository-aware capture (repository, branch,
  commit, file and line context).
- Design any Linear/GitHub imports separately. Keep Linear authoritative for
  issue state, GitHub authoritative for PR/CI state, and Org authoritative for
  personal notes. Do not implement bidirectional synchronization without
  explicit conflict and ownership rules.

## Validation already completed

The Doom change passed strict OpenSpec validation, formatting/lint checks,
flake evaluation, stable and unstable consumer builds, the Kitsune system
closure build, isolated Org/Babel/Citar/TeX tests, and the disposable graphical
session VM. No generation was activated. See
[`emacs-science-validation.md`](emacs-science-validation.md) and
[`emacs-org-validation.md`](emacs-org-validation.md) for details.

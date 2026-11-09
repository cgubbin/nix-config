# Emacs handoff

This handoff accompanies the declarative Doom/Org feature and the completed
OpenSpec changes `add-declarative-doom-org` and
`add-scientific-org-and-dashboard`. The feature is on `explore/doom-org` and
has been build- and VM-checked without activating a system generation.

## Ready to try on Kitsune

The Kitsune Home Manager profile enables the shared feature with notes rooted
at `/home/kit/notes/personal`. After merging, committing and pulling the
configuration, rebuild only when ready:

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

The separate repository is `/home/kit/Repos/wsl-nix-config`. It uses
flake-file/dendritic modules and its own unstable nixpkgs. Add a pinned flake
input for this configuration repository, then import its
`flake.modules.homeManager.shared-doom-emacs` module into the `kit` Home Manager
profile (or `home-manager.sharedModules` for the WSL host). Set a work-only root
such as `/home/kit/notes/work`, keep graphical integration disabled, and leave
the default on-demand daemon behavior available. Do not sync this tree to
personal devices.

The work profile should be configured and evaluated in its own repository;
the personal feature's module accepts the consumer's package set and does not
require sharing its note files. Pin the feature repository to the reviewed
merge commit instead of following a moving branch. Build the `work` system
closure first, inspect the input lock changes, then activate using the work
repository's documented NixOS-on-WSL command. After a WSL shutdown/start, test
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

# Proposal

## Why

The declarative Doom foundation supports capturing and linking notes, but does not yet provide the scientific writing, reproducible calculation and citation workflow requested for physics, mathematics and engineering. Its current configuration also lacks Doom's dashboard, leaving the knowledge application without an intentional starting screen.

## What Changes

- Enable a Doom dashboard with a clear visual identity and shortcuts to capture, agenda, knowledge search and daily notes.
- Add a bounded, Nix-managed TeX preview toolchain and configure equation previews, inline images and attachment-friendly links.
- Configure Citar and Org citations against a host-local BibTeX file and optional local paper directory, without an external reference service.
- Support Org Babel for Python, shell and Emacs Lisp, with explicit evaluation confirmation and documented per-block uv/Pixi or environment selection. Never hard-code one interpreter for all projects or execute blocks merely by opening or exporting a document.
- Add small, distinct templates for physical concepts, mathematical derivations, algorithms, papers and numerical experiments.
- Provide and validate an example derivation, generated figure, citation and Org-roam link, including HTML export.
- Document use, package provenance, tests and the outstanding graphical and WSLg checks.

## Capabilities

### New Capabilities

- `doom-dashboard`: A discoverable knowledge-focused startup screen for graphical and terminal use.
- `scientific-org`: Equations, safe calculations, figures, citations, scientific note templates and export.

### Modified Capabilities

None. The foundation change `add-declarative-doom-org` has completed tasks but has not yet been archived into main specs; this change depends on its behaviour and must be reconciled when the foundation is archived.

## Impact

This change builds on the uncommitted foundation in `/tmp/nix-config-doom-org`. It affects its Doom Lisp, Home Manager package inputs, tests, example documents and documentation. Nixvim, existing user notes, the separate work repository and the active system are outside scope. Project/ADR templates and tracker integration remain later work.

An initial implementation spike was started before this proposal: dashboard selection, a Citar declaration, a TeX list and `science.el` exist in the worktree. It has not passed evaluation: this pinned nixpkgs has no top-level `pkgs.dvisvgm`. Treat those edits as unvalidated draft input for implementation, not as accepted behaviour or completed tasks.

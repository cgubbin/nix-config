# Design

## Context

The completed but unarchived `add-declarative-doom-org` change supplies a shared Home Manager feature, Doom's Org module with `+roam`, a single daemon, capture-frame helpers and isolated stable/unstable consumer and VM checks. It keeps Org roots separate and user data outside the store. The current worktree contains both that uncommitted foundation and the unvalidated spike described in proposal.md. Do not discard either; inspect and correct the spike as part of apply.

Pinned Doom's `:ui dashboard` ships a banner and ASCII fallback without a separate dashboard package. Its Org module lazy-loads Babel and `+org-init-babel-h` sets `org-confirm-babel-evaluate` to nil; a test of the variable before the actual execution path is insufficient. Pinned Org's Python backend supports the per-block `:python` header. The integration uses Nix-built dependencies rather than runtime package installation.

## Goals / Non-Goals

**Goals:** Make the knowledge app useful for scientific notes; keep project interpreters selected locally and evaluation explicit; preserve the daemon/capture lifecycle and existing notes. Verify against the two pinned consumer package sets.

**Non-Goals:** Turn Emacs into an IDE, create a reference-manager service, change note synchronisation, deploy to Kitsune or modify the work repo. Engineering ADR/project templates and Linear/GitHub API integration are separate changes. PDF export is optional; HTML and equation previews are required.

## Decisions

### Dashboard

Enable the pinned Doom `:ui dashboard` module and use its built-in graphical banner and text fallback; use a small curated menu linking capture, agenda, Org-roam search, daily journal and recent files. Prefer repository-native Lisp and Doom's existing assets over adding a generated bitmap or another dashboard framework. Ensure actions are callable even when Org is lazily loaded. Keep the existing external capture frame special-case and test dashboard activation does not replace it. Verify any needed icon fonts are Nix-managed on both consumers; provide readable labels without those fonts.

### Equation tools and images

Select a limited TeX package set using the pinned nixpkgs' supported `texlive.withPackages` interface and the actual location of `dvisvgm` or an equivalent renderer. The spike's `pkgs.dvisvgm` attribute is demonstrably invalid; inspect pinned stable and work-like unstable package definitions before choosing. Test real inline and display fragment conversion, regeneration after edits and required fonts/packages instead of assuming package names. Configure image preview and relative links; leave user figures and PDFs in writable note directories. Do not fetch TeX packages at runtime or install a full TeX scheme by default.

### Bibliography and citations

Use Citar from the Nix-built Emacs package set, not an independently managed package. Point Org citation and Citar defaults to `bibliography/references.bib` under the selected Org root and optional papers under that root; allow standard Org buffer/file bibliography overrides. Create missing directories/files idempotently and never overwrite existing bibliography or papers. Use a supported Org citation export processor and test the actual resulting HTML citation and bibliography. Do not use real user bibliographic data in tests.

### Explicit Babel execution and environments

Use Org's built-in `ob-python`, `ob-shell` and `ob-emacs-lisp`. Preserve confirmation on the actual execution path after Doom's lazy initialization and disable implicit evaluation during HTML export. Test refusal of a real execution request, not only the variable value. Document per-block `:python`, project-local virtual environments and explicit `:dir` for commands such as uv or Pixi; validate command argument handling against the pinned Org backend and document executable availability. Do not automatically run package managers, resolve dependencies, activate shells or trust file-local evaluation settings when opening a note. Python session and non-session blocks have different interpreter semantics; test and document whichever modes are supported.

### Templates and example

Extend Org-roam's capture menu with five short distinct templates; retain the foundation's inbox/engineering templates and stable IDs. Each scientific note should accommodate assumptions, derivation or method, validation, references and related concepts where relevant without enforcing a deep directory hierarchy. Supply a small standalone example and a second node plus a synthetic BibTeX file in the repository. The example must produce a figure in a temporary copied directory after explicit consent, render both equation forms, resolve a citation and node link, and export HTML without running source blocks implicitly. A deterministic standard-library Python figure is acceptable; do not require a global plotting stack just to run the example.

### Validation and lifecycle

First fix the invalid spike and build a small baseline. Extend existing offline startup, scratch-data and disposable VM tests rather than touching the active user service. Run stable and unstable Home Manager builds, relevant lint/format and flake checks, actual TeX rendering, citations, both supported Babel environment modes and HTML export. Validate the example's rendered output and figure links, and check a declining-confirmation path leaves no side effect. The dashboard's Xvfb frame and terminal fallback can be tested in isolation; actual Kitsune Wayland/Hyprland focus, WSLg restart and the work repository remain separately reported. Document exact host activation/testing commands and do not switch generations without explicit permission.

## Risks / Trade-offs

- [Package names and dependencies differ across pinned channels] -> inspect and build each consumer; do not equate a package attribute evaluating with working rendering.
- [Doom lazy initialization can reset evaluation safety] -> test confirmation when a block is actually evaluated and test export independently.
- [Daemon inherits stale graphical or project environment] -> choose execution environment per block and retain existing session helpers; do not mutate daemon-wide PATH per project.
- [Mixed uncommitted foundation and spike] -> keep tracked task accounting honest, preserve all user data and compare changes against the foundation before claiming completion.
- [Dashboard can interfere with temporary capture frames] -> exercise both finalisation and abort through the existing VM test.
- [TeX closure size grows] -> document selected packages and closure impact; only extend the set when real preview/export evidence requires it.

## Migration Plan

1. Verify the completed foundation baseline and diagnose the initial draft's failed dependency evaluation; preserve its existing files.
2. Implement and validate dashboard and scientific features incrementally, keeping all runtime state in writable host roots.
3. Run integration checks and document user actions, limitations and rollback. Reverting the generation and restarting the service restores prior configuration; note data and bibliography are not rolled back.
4. Archive or sync the foundation and this change in an order that preserves their separate capability specs, after review. Work-host adoption and activation require separate user requests.

# Proposal

## Why

The shared Doom setup already supports safe Org Babel execution, scientific notes, and repository-context engineering notes, but project TODOs still live in one global task file. The work needs a project-local workflow that works when Emacs is entered from Neovim or Zellij, while keeping personal and work task files private to their respective Org roots. We should also close the known gap between configured scientific previews and reproducible PDF export, and make the Work/WSL adoption path testable.

## What Changes

- Add a Nix-managed Projectile and Org project-capture workflow for project-local TODOs stored beneath each host's private Org root, never in source repositories.
- Make project TODOs discoverable in the global agenda and provide project-scoped capture and agenda commands both inside Emacs and from terminal callers that pass the Git root.
- Define task states and project metadata that support personal execution without mirroring Linear or GitHub issue state.
- Correct and validate repository source links in engineering notes so paths resolve from the note location and durable references can use commit permalinks.
- Complete the scientific document workflow with a Nix-managed PDF export toolchain and a reproducible example covering equations, citations, figures, and Python output, while preserving Babel confirmation safeguards.
- Document adoption by a separate Work/WSL consumer and add headless checks for daemon, terminal capture, project agenda discovery, and export. Record graphical WSL behavior as unverified unless tested on that host.

## Capabilities

### New Capabilities

- `org-project-workflows`: Private per-project TODO capture, agenda integration, repository-aware entry points, and durable source references.
- `scientific-document-export`: Nix-provided export dependencies and safe, reproducible export of scientific Org documents to PDF.

### Modified Capabilities

None. No main specifications are currently registered; these capabilities establish the requirements for the new behavior.

## Impact

The change affects the shared Home Manager Doom module and its Emacs Lisp, shell entry points, package declarations, tests, and Org documentation. It adds Nix-managed Emacs dependencies and a focused TeX export toolchain. The independent Work configuration is maintained elsewhere, so this repository can provide and validate the consumer interface and migration instructions but cannot activate that separate configuration. Linear and GitHub remain authoritative for shared issue and pull-request state; this change adds no synchronization, credentials, or write-back.

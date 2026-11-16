# Proposal

## Why

The Org environment already supports scientific notes, citations, project TODOs, and repository context, but PDF reading and external issue/PR references still require manual context switching. Adding declarative PDF annotation and clear Linear/GitHub link workflows will make the notes useful for paper review and software work without creating a competing issue tracker.

## What Changes

- Add Nix-managed Org-noter and image-capture packages; support synchronized annotation in graphical Emacs sessions and page-linked Org notes opened in Zathura for terminal-first WSL use.
- Extend the paper-reading template with bibliographic metadata, claims, evidence, limitations, and links to a local PDF and related notes; capture figures into the note tree with relative paths.
- Add consistent Org links and properties for Linear issues and GitHub issues/pull requests, with commands or links that open the external records.
- Enable Forge through the existing Magit integration for browsing GitHub issues and pull requests in Emacs, using credentials supplied outside the Nix store.
- Document everyday paper-review and engineering issue/PR workflows, including how Org and Linear/GitHub retain separate ownership.
- Keep all packages and configuration reproducible through the existing Nix-managed Doom profile.

## Capabilities

### New Capabilities

- `org-document-reading`: Read local PDFs with Org-linked notes, annotate papers, and capture figures as writable note assets.

### Modified Capabilities

- `org-project-workflows`: Extend project notes and tasks with durable Linear and GitHub issue/PR references and clear authority boundaries.

## Impact

- Emacs package profile and Doom Org/Magit configuration under `modules/applications/emacs/`.
- Org project and scientific note templates, plus `docs/emacs-org.md` and the consumer handoff/validation documentation.
- Offline Nix package/build tests and Emacs smoke tests for link handling, package loading, and PDF note workflows.
- No new flake input is expected; package availability and native PDF dependencies must be verified against the repository's pinned package sets.
- No credentials, API tokens, issue-state imports, generated agendas, or write-back synchronization are introduced. Linear remains authoritative for shared issue state, GitHub for PR/CI state, and Org for personal notes and local planning.

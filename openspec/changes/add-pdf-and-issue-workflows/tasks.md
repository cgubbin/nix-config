# Tasks

## 1. Declarative PDF reading packages

- [x] 1.1 Verify `org-noter`, `pdf-tools`, and `org-download` package attributes and dependencies in the pinned consumer, stable, and unstable package sets; record any closure impact and confirm no package installation occurs at Emacs startup.
- [x] 1.2 Add the verified packages through the existing Nix-built Doom profile, configure Org-noter for graphical Emacs only, and verify profile builds plus a headless package-load smoke test.
- [x] 1.3 Configure image capture to use writable per-note assets and relative links; verify an inserted local image link resolves from a copied note tree and document clipboard/screenshot requirements.

## 2. WSL and Zathura paper-reading workflow

- [x] 2.1 Add an Org Zathura link format and safe launcher for validated local PDF paths and page numbers; test argument handling with a mock viewer, including spaces, invalid pages, missing files, and absent display sockets.
- [x] 2.2 Pass validated WSLg display values from a terminal Org client only to the Zathura child process; test that launching Zathura does not set display variables on the systemd user manager or daemon.
- [x] 2.3 Extend the paper-reading template with citation metadata, local PDF links, page-linked findings, claims, evidence, limitations, and related notes; test a complete example note and document the WSL Zathura flow.

## 3. Linear and GitHub reference workflows

- [x] 3.1 Add documented Org properties/link conventions for Linear issue IDs and URLs, GitHub issues/PRs, repository links, and relevant commits; verify links open externally and remain plain Org text.
- [x] 3.2 Enable the pinned Doom Forge integration for GitHub repository issues and PRs; verify stable/unstable profile builds and unauthenticated Org links, then document a live authenticated Forge check for consumers that configure credentials outside Nix.
- [x] 3.3 Verify that credentials are not embedded in Nix derivations or the store, and test/document that Org does not import, overwrite, or synchronize external issue state.
- [x] 3.4 Extend project, investigation, benchmark, and ADR workflow documentation with links between notes and external records; execute test-environment commands and identify live-account commands for manual verification.

## 4. Cross-workflow validation and handoff

- [x] 4.1 Add or extend headless Emacs tests for Org-noter package loading, Zathura link parsing, local paper links, Citar integration, Forge loading, and existing project workflows; run the Doom startup check.
- [x] 4.2 Build stable and unstable Home Manager Doom profiles, run Nix formatting and shell checks, and validate all new OpenSpec specs strictly.
- [x] 4.3 Update the Work/WSL handoff with package activation, Zathura/WSLg diagnostics, optional graphical Org-noter usage, Forge credential setup locations, and explicit manual tests not covered by the headless environment.

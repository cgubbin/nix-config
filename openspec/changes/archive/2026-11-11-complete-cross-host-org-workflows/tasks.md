# Tasks

## 1. Project task storage and package integration

- [x] 1.1 Declare the pinned Projectile and Org project-capture packages through the existing Nix/Doom package mechanism; verify the stable and unstable Doom package checks evaluate and build.
- [x] 1.2 Implement collision-resistant project identity and private TODO sidecar paths beneath `knowledge.orgDirectory`; add tests proving same-basename repositories remain separate and no repository files are created.
- [x] 1.3 Implement project task capture for an explicit validated Git root and the current Emacs project; add tests for both paths, missing context, and invalid roots.
- [x] 1.4 Document project TODO location, project registration, task states, and how tasks remain private and separate from Linear/GitHub; verify commands and paths against the implementation.

## 2. Agenda and terminal workflow

- [x] 2.1 Add bounded agenda discovery for registered project TODO files while preserving inbox and agenda files; test that missing sidecars are skipped and unrelated repositories are never scanned.
- [x] 2.2 Add project-only agenda navigation and terminal capture arguments for repository roots; test capture and agenda against a daemon whose current buffer belongs to a different project.
- [x] 2.3 Integrate project TODO capture with existing shell and Zellij entry points without changing Neovim keymaps; verify capture returns to the caller and the task appears in the global agenda.
- [x] 2.4 Update the user guide with the project capture and agenda commands, supported Emacs project behavior, repository-context requirements, and failure diagnostics; run each documented terminal command in the test environment.

## 3. Repository-aware engineering links

- [x] 3.1 Correct `org-project-capture` source links to resolve from the recorded repository root, retaining commit, file, and line metadata; test local links from notes stored under `roam/`.
- [x] 3.2 Add commit permalink generation when a usable remote is available and test absent remotes, uncommitted changes, and private/local repository fallback.
- [x] 3.3 Update the engineering note documentation with local and durable link behavior; verify examples open the expected source location.

## 4. Scientific PDF export

- [x] 4.1 Add the narrow Nix-managed LaTeX export dependencies and supported document class; verify the Doom profile and stable/unstable package checks build and record the added closure size.
- [x] 4.2 Extend the scientific example to exercise a derivation, confirmed Python figure generation, citation, and linked figure in PDF output; test the generated PDF contents and verify export itself does not execute Babel blocks.
- [x] 4.3 Document PDF export, bibliography setup, figure paths, and required source-block confirmation; run the documented export from a clean writable copy of the example.

## 5. Cross-host adoption and integration validation

- [x] 5.1 Update the consumer handoff for Work/WSL with the required feature input/import, private Org root, terminal-only daemon options, upgrade commands, and diagnostics; verify every command against the shared module interface.
- [x] 5.2 Add or update headless integration checks for daemon startup with display variables unset, terminal capture, project agenda discovery, and PDF export; run the repository's relevant Nix and Emacs checks.
- [x] 5.3 Record which graphical behaviors require manual Kitsune or Work/WSL testing and confirm no validation claim implies WSLg was exercised in a headless environment.

## Workflow follow-up

- Validate and archive this change after implementation review.
- On the work machine, update the separate WSL configuration to consume the reviewed shared feature, then activate and verify terminal capture and project agenda behavior using its private Org root.
- Verify graphical frame behavior on Kitsune; test WSLg frames only if that work configuration enables graphical integration.

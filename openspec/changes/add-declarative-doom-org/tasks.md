# Tasks

## 1. Reconcile the completed refactor

- [x] 1.1 Rebase this change onto the completed module migration, preserving its OpenSpec configuration and existing changes; verify git status and the resulting planning diff contain no lost or unrelated edits. Do not reproduce the migration if its completed base is unavailable.
- [x] 1.2 Map the final public export, Kitsune composition, vanilla Emacs import, UWSM lifecycle and consumer fixture paths; record the target paths and baseline Neovim generated configuration in the implementation validation record.

## 2. Milestone 1 — Declarative foundation

- [x] 2.1 Select and lock an Unstraightened revision with its Doom/core/modules and emacs-overlay dependencies; inspect that exact revision's module options and package mechanism, record provenance, and verify unrelated input revisions remain unchanged.
- [x] 2.2 Register the independently selected shared-doom-emacs Home Manager feature with documented orgDirectory, enableDaemon and enableGraphicalIntegration options using consumer pkgs; verify selected and unselected fixtures and reject invalid Org roots.
- [x] 2.3 Add minimal Doom Lisp for Evil, completion, discoverable navigation, graphical defaults, Org and Magit using the selected release's real module names; build the final Doom package and verify its configured profile and packages load in an isolated startup smoke check.
- [x] 2.4 Select Doom in Kitsune and remove its competing vanilla Emacs selection; evaluate the host and compare Neovim generated configuration with the baseline to verify no editor regression.
- [x] 2.5 Extend the refactor's pinned stable and work-like unstable consumer fixtures; build their Doom packages and Home Manager activation packages, verify no personal secrets or desktop services are required, and build Kitsune's Home Manager activation package without activating it.
- [x] 2.6 Document feature selection, declarative package/module changes, lock updates and generation rollback in docs/emacs-org.md; verify documented build commands against actual outputs and record Milestone 1 results before continuing.

## 3. Milestone 2 — Daemon and launch workflow

- [x] 3.1 Configure one Home Manager systemd user service with the final Doom package and consistent socket identity; verify evaluated unit contents and isolated tests for startup, concurrent starts, readiness timeout and restart without touching the live user service.
- [x] 3.2 Package org-capture, org-agenda and org-notes helpers with safe argument encoding and explicit client paths; verify helper dispatch, special-character arguments, missing-display errors and absence of alternate-editor duplicate daemon spawning.
- [x] 3.3 Implement small marked capture frames using standard Org hooks and minimal cleanup Lisp; verify finalise, abort and ordinary capture cleanup in isolated tests, and provide a manual graphical checklist for frame closure and focus return.
- [x] 3.4 Integrate Kitsune with its evaluated UWSM session lifecycle and current display environment; verify unit target/environment dependencies and choose capture/agenda bindings absent from the final binding set.
- [x] 3.5 Implement on-demand environment handling suitable for WSLg consumers, including stale-variable treatment and bounded failures; test with synthetic session environments and document that real WSL restart/frame checks remain pending until performed.
- [x] 3.6 Verify disabling daemon support omits daemon helpers/shortcuts while ordinary Doom remains available; document client file opening, independent restart, journal diagnosis and a Windows wsl.exe shortcut example, and record Milestone 2 automated versus manual results before continuing.

## 4. Milestone 3 subset — Minimal knowledge workflow

- [x] 4.1 Configure the shallow writable note layout and idempotent first-use creation using the host Org root; verify scratch roots remain separate, existing content survives repeated setup and rebuild, and no sync or store-managed note files are introduced.
- [x] 4.2 Add inbox, TODO, scientific concept, engineering investigation and meeting templates with agenda scope; capture each into temporary notes and verify actionable TODO entries appear in the agenda without manual path selection.
- [x] 4.3 Enable the pinned Doom Org-roam integration with a writable host-local database, node creation/search and backlinks; verify two scratch nodes retain stable ID links and backlinks after database synchronisation.
- [x] 4.4 Configure dated daily notes and navigation through the standard dailies workflow; verify repeated creation on the same date reuses the existing note without overwriting content.
- [x] 4.5 Preserve Babel confirmation and absence of automatic execution hooks; verify opening a scratch Org document with a side-effecting block does not execute it, and document the intentionally deferred scientific environment-selection work.
- [x] 4.6 Document capture keys, agenda, node links/backlinks, daily navigation, independent personal/work roots and runtime data locations; verify examples against the scratch-data smoke checks and record the Milestone 3 subset results.

## 5. Integration validation and handoff

- [x] 5.1 Run repository formatting/lint checks, flake checks, Kitsune evaluation and the supported host system build without activation; record exact commands and distinguish passing results from input-access or build blockers.
- [x] 5.2 Run the final packaged Doom startup with a temporary HOME/runtime and networking unavailable; verify the intended profile, Evil, Org and Org-roam load without downloads and that scratch capture/agenda/link tests still pass.
- [x] 5.3 Review the final diff for unchanged Nixvim behaviour, no secrets or note contents in managed files, no unrelated input updates and no work-repository edits; publish a concise validation report with exact activation/manual-test commands and explicit GUI/WSLg verification status.

## Workflow follow-up

- Activate only on a separate explicit request; then test graphical frames, capture focus return and frame closure on Kitsune.
- Adopt the exported feature into the separately owned work repository on a separate request, using its locked inputs and independent note root; test actual WSLg availability and repeated WSL shutdown/start cycles before declaring work-host acceptance complete.
- Propose Milestone 4 separately: bounded TeX dependencies, citations, notebook-specific uv/Pixi Babel execution, scientific templates and an HTML-export example.
- Propose Milestone 5 separately: project/ADR templates and repository-context capture. Keep Linear/GitHub links lightweight and design any later read-only imports with explicit ownership; bidirectional synchronisation remains out of scope.

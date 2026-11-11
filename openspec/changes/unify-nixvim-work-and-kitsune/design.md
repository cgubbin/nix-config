# Design

## Context

See proposal.md for motivation. The existing `shared-editor` export in `modules/shared/features.nix` composes the Kitsune Nixvim modules and has stable/work-like synthetic consumers. The actual work repository is clean at inspection and composes `home/kit` with `inputs.import-tree`, has a separately pinned unstable Nixvim companion, and declares flake inputs via flake-file rather than editing generated flake.nix.

The work tree adds `python-env.nix`, changes DAP/Neotest to call its resolver, adds a private quarto-sync plugin and hooks, and differs in editor assets and settings. Its Obsidian configuration, optional Claude integration and work-specific tooling require deliberate preservation. Work's resolver mutates global `vim.env` asynchronously, marks loads complete before success, caches by root, may invoke missing Pixi, and appends paths to a fixed `/tmp` file. Its notebook creator opens a target in write mode. Completion sources are declared in both completion and LSP modules; test args assume pytest-xdist. These are source observations; actual runtime behaviour remains to be verified.

## Goals / Non-Goals

**Goals:** Make the user's newer work behaviour the comparison baseline, remove duplicate ownership, make each intentional deviation reviewable, and verify actual editor behaviour rather than derivation evaluation alone.

**Non-Goals:** Unify unrelated work Git, shell, CLI, host or secrets configuration; refresh production inputs; activate either host; publish commits or private work sources; automatically add every suggested package. This repo-local change cannot edit the separate work repository; it delivers a concrete integration patch and validation instructions, with actual adoption tracked as a required follow-up.

## Decisions

### 1. Work-first shared baseline and explicit extensions

Compare each work file and asset against the current shared editor, recording work-only, personal-only and common behaviour before moving code. Promote work's portable navigation, completion, Python resolver, DAP, Neotest, notebook and snippet behaviour to the shared modules. Keep the export name `flake.modules.homeManager.shared-editor` and make configurable integrations opt-in, with defaults and extension points preserving existing consumers. Preserve personal vaults and work vaults as separate consumer modules; keep machine paths and terminal clipboard/image backends configurable. Inspect the Claude file's actual import status before treating it as active.

Quarto-sync has a private Git input: keep a consumer-supplied package/module and conditional setup, not an unconditional producer input. A consumer with the plugin configured retains work's preview/sync workflow; other consumers still have the common Quarto/Molten baseline. Retain the consumer-supplied Nixvim companion and pkgs, including work's unstable-specific overlay. Preserve each consumer's original stateVersion, username, identity and package pins.

Alternatives: overlaying both full trees causes duplicate module definitions and implicit personal/work behaviour. Selecting the personal baseline would discard the user's explicitly preferred work improvements. A new third repository is unnecessary for the initial adoption.

### 2. Project-scoped environment and interpreter selection

Capture a clean editor-start environment, load direnv only when allowed, validate its output including removals, and apply results to project-scoped test, DAP and LSP process launches rather than indiscriminately mutating global `vim.env`. Use project identity and generation tokens so delayed callbacks from A cannot apply to B. Avoid caching failures or treating an unapproved environment as loaded. Provide an explicit refresh and invalidate on relevant project/env changes; provide an actionable diagnostic if export fails. If integration requires a global environment for a particular plugin, restore the clean base plus current project's full diff on buffer transitions, restart affected subprocesses, and prove A/B/A isolation; do not claim isolation without tests.

Use a single resolver shared by Neotest and DAP, with project-aware roots, documented precedence, executable checks, bounded/nonblocking invocation and recoverable failures. Invoke Pixi only when present and an explicit Pixi manifest/configuration is detected; avoid environment creation or network activity merely by opening a generic pyproject. Prefer the existing valid project environment, then `.venv`, then available Python with a visible failure when none exists. Invalidate stale cache entries and clear pending state on failures. Do not log paths to a predictable shared temporary file by default.

Tests cover two independent projects A/B/A, removed variables, delayed callbacks, failed/unapproved direnv followed by retry, missing/slow Pixi, normal Python projects without Pixi, valid Pixi, changed environments, missing interpreters, and DAP/Neotest agreement. Project environments are not a security sandbox and execute only explicitly approved direnv configurations.

### 3. Targeted audit fixes and practical capabilities

Create notebooks exclusively at a new path, or offer explicit confirmation before replacing an existing file; prove the original bytes survive a rejected replacement. Define completion sources in one place and enable only installed source plugins. Drop unconditional pytest `-n 0` unless xdist availability is verified. Make the editor-config shortcut consumer-configurable, with no silent reference to the retired layout. Inspect pinned Overseer APIs before consolidating its duplicate setup; test task execution and missing toggleterm handling. Assess Rust toolchain selection, Python/ruff LSP diagnostic overlap, clipboard backend, notebook image/terminal compatibility, remote image fetching, debug adapter availability and error reporting. Fix demonstrated regressions within these workflows; record optional tools as recommendations instead of mandating new global packages.

The pinned work Jupytext plugin reuses and overwrites a sibling Markdown file when saving a notebook. The user selected isolated temporary conversion files on 2026-11-10: notebook editing keeps the work conversion format but does not read, modify, or remove adjacent paired Markdown files. Test the behavior with an existing sibling file, repeated saves and buffer unload on both pinned consumers.

Write `docs/nixvim-audit.md` with file/line evidence, effect, disposition and verification; include a basic health/status path for installed LSP, formatters, runtimes, parsers, clipboard, adapters and kernels. Do not assume all tools belong in the system profile when a project environment supplies them.

### 4. Consumer patch and rollout boundaries

Create a reviewable patch and companion instructions under this repository, based on the exact work Git revision captured at implementation time. Test `git apply --check` and apply it only to an isolated temporary copy/worktree within permitted writable roots; do not alter the external repository under this change. The patch adds an input declaration through work's flake-file modules, retains the work Nixvim companion and dependencies, excludes the entire old editor tree from recursive import-tree discovery, and relocates only genuine work extensions outside the excluded tree. Regenerate flake.nix in the isolated copy using the existing work workflow and ensure its generated diff is included. Detect work changes before applying; never overwrite concurrent changes or pin a `path:/home/kit/...` URL in the committed work lockfile.

Test an isolated consumer assembled from that patched work baseline with its pinned inputs and local overrides for unavailable private dependencies. Test fixtures must make substitutions explicit and cannot be represented as an actual work-host build. Document acquiring/publishing a reviewed immutable producer revision, applying the patch in the separately owned repository using an authorized write workflow, updating only its producer lock entry, evaluating/building the real WSL host with its private inputs, and rollback of both source and lockfile. The actual work adoption, work-host build and WSL runtime checks are a required follow-up and must not be marked completed by synthetic tests.

### 5. Validation and dependency policy

Keep the existing stable and work-pinned unstable fixture stacks; use the consumer's own Nixvim and package set. Reuse existing fixture overlay workarounds where needed. Add headless Neovim checks for startup, relevant mappings/autocmds, safe notebook creation and project environment scenarios, plus representative disposable Python pytest, DAP and Quarto workflows using local test fixtures. Where a real terminal, external program or private integration is necessary, provide exact manual checks and report them separately; no build-only check is proof of interactive behaviour. Build Kitsune without activation, compare affected editor settings to both baselines and document intentional deviations.

## Risks / Trade-offs

- Work settings depend on newer Nixvim APIs or plugins absent from stable -> gate optional integrations and verify actual pinned versions in both consumers; do not silently substitute personal behaviour.
- Async environment updates can race or leak -> use per-project state and generation checks, test A/B/A and cancellation, and avoid long-lived global mutation.
- Global editor configurations may include paths or private dependencies -> make work/personal plugins explicit, verify synthetic consumers without them, and never copy secrets into fixtures or the patch.
- Recursive auto-import can retain duplicate editor code -> exercise the generated patched consumer with an assertion that hooks and keymaps occur once.
- Scope crosses repository permissions -> keep this change's edits inside its declared root; stage the work patch in a writable isolated copy and use a separately authorized workflow for actual adoption.
- Headless tests cannot prove WSL terminal/GUI behaviour -> document those manual tests as pending until performed on the real host.

## Migration Plan

1. Record work commit, local status, input pins and observable editor baseline; retain existing user changes. Inventory editor differences and classify them with work precedence.
2. Refactor the shared baseline and extensions, fix confirmed defects, and run focused tests and the audit as each area changes.
3. Build and test both synthetic consumers and the Kitsune system closure without activation. Review resulting settings, behaviour changes and dependencies.
4. Produce and test the consumer patch in an isolated copy and document the exact pin, regeneration, work-host validation and rollback. Do not mark the actual work-host adoption as performed.
5. In a separately authorized work-repository workflow, publish/access a reviewed producer revision, apply the patch, update only its producer lock entry and validate the real work host. Keep previous Git commits and locks for rollback.

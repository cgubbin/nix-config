# Tasks

## 1. Establish work-first baseline

- [x] 1.1 Record both repository revisions, worktree status, work input pins, editor module discovery and generated editor settings; verify existing user changes and private inputs are not copied or exposed.
- [x] 1.2 Compare work and Kitsune editor files, assets, keymaps, plugins and Lua hooks; write a work-first inventory distinguishing portable features, machine extensions, known defects and intentional differences, and verify every meaningful difference has a disposition.

## 2. Consolidate shared editor and consumer extensions

- [x] 2.1 Port work's portable editor options, completion, navigation, snippets and editor assets into the existing shared export; verify generated settings against the work baseline and check that completion sources are configured once and installed.
- [x] 2.2 Split personal/work vaults, clipboard/image terminal settings and configuration-directory shortcut into consumer-supplied options or modules; verify each synthetic consumer selects its own values and the retired hard-coded path is absent.
- [x] 2.3 Extract optional quarto-sync and other private or work-specific integrations behind consumer-supplied inputs; verify the common editor starts without private inputs and a work-like extension starts once when supplied.
- [x] 2.4 Preserve and audit work-specific plugins, including whether Claude integration is actually imported, and retain appropriate extension points; verify no duplicate keymaps or autocmds arise from composition.

## 3. Project environments, tests and debugging

- [x] 3.1 Implement project-scoped approved direnv loading with removal handling, async race protection, retry and refresh; verify A/B/A subprocess environments, failed/unapproved loads, removed variables and stale callback ordering with focused headless tests.
- [x] 3.2 Implement a shared project-aware Python resolver for DAP and Neotest with guarded Pixi discovery, `.venv` and Python fallbacks, bounded failure handling and cache invalidation; verify missing/slow Pixi, non-Pixi pyproject, environment changes, missing executables and matching DAP/test selection.
- [x] 3.3 Remove fixed temporary path logging and the unconditional pytest-xdist argument; verify a pytest-only project runs selected tests and no editor-created resolver log appears in a shared temporary path.
- [x] 3.4 Reconcile work's DAP, Neotest and Rust toolchain settings with the shared baseline; verify representative disposable Python debug/test and Rust project workflows with explicit dependency requirements.

## 4. Notebook and task workflows

- [x] 4.1 Prevent NewNotebook from silently overwriting existing files while retaining creation of valid new notebooks; verify new, existing/declined and explicit replacement scenarios using disposable files.
- [x] 4.2 Merge the work Quarto/Molten workflow and consumer-supplied Quarto-sync hooks without double setup; verify headless initialization and a representative disposable notebook/preview path, recording GUI-only checks separately.
- [x] 4.3 Audit Overseer setup, toggleterm dependency and pinned plugin APIs; consolidate any demonstrated duplicate setup and verify task execution and useful failure reporting when optional dependencies are absent.
- [x] 4.4 Assess project health reporting, LSP/formatter overlap, notebook image/clipboard backends, remote image fetching and debug adapter availability; write `docs/nixvim-audit.md` with evidence, severity, tested status and fix/defer/recommendation for each finding.

## 5. Consumer compatibility and work adoption patch

- [x] 5.1 Extend both stable and work-pinned unstable consumer fixtures with editor extensions and headless startup, keymap, autocmd and project-workflow checks; verify they use consumer pkgs/Nixvim and need no private inputs.
- [x] 5.2 Build both editor consumers and Kitsune without activation; compare generated editor settings and intentional deviations against the recorded work baseline and verify retained pins/state versions.
- [x] 5.3 Produce a work-repository patch from the recorded work baseline that adds a flake-file input, excludes the entire old editor tree from recursive discovery, preserves the companion module and work extensions, and includes regenerated flake.nix; verify `git apply --check` and no tracked local-path lock input.
- [x] 5.4 Apply the patch only to a disposable copy within an allowed writable root and test a work-like consumer with explicit substitutions for unavailable private inputs; verify a single shared editor, expected extensions and absence of duplicate mappings/hooks, and distinguish the fixture from the actual work host.
- [x] 5.5 Update `docs/shared-features.md` with export options, exact companion/optional dependencies, compatibility pins, patch baseline and application, flake-file regeneration, reviewed-revision pinning, real-host build/runtime checks, and rollback; verify examples against the isolated patched copy.

## 6. Integrated validation

- [x] 6.1 Run required lint, both consumer checks, behavioural tests and a non-activating Kitsune build; verify results and record any environment-dependent checks as pending rather than passed.
- [x] 6.2 Review the change, audit and patch for work precedence, preserved secrets/identity, no unapproved pin updates and no external-repository mutations; verify all differences have documented rationale and the actual WSL adoption remains explicitly outstanding.

## Workflow follow-up

- In a separately authorized work-repository workflow, apply the reviewed patch against the verified work revision, pin a published producer revision, build/evaluate the real WSL host with its actual inputs, and perform the documented interactive Python, debugging, notebook, clipboard and terminal checks. Retain previous commits/lockfile for rollback; do not claim full cross-repository adoption until these pass.

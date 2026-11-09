# Design

## Context

See proposal.md for motivation and the three capability specs for behaviour. This planning worktree starts at `4c929fe`, where the legacy flake exposes Kitsune, work and MacBook and forwards inputs through specialArgs/extraSpecialArgs. The separate dirty checkout at `/home/kit/nix-config` is migrating to flake-parts/import-tree, named module exports and Kitsune-only ownership. Its vanilla Emacs module is imported by the global tools profile; Neovim has a separate shared-editor export. Kitsune enters Hyprland through UWSM. The work configuration now has a separate repository using unstable inputs.

The migration is an implementation prerequisite, not work to reproduce here. Exact final composition paths must be reconciled after rebasing. No WSL runtime is accessible from this native Linux environment.

## Goals / Non-Goals

**Goals:** Keep installation immutable, data writable, service ownership singular and the public feature useful to a consumer with its own package set and identity. Finish each milestone's available checks before proceeding, recording runtime checks separately.

**Non-Goals:** Modify the work repository, restore retired machine outputs, replace Neovim, install an IDE stack, provision a full scientific toolchain, import issue databases or activate the configuration.

## Decisions

### Integrate after the module migration

Rebase this planning branch onto the completed refactor before implementing. Register `flake.modules.homeManager.shared-doom-emacs` from a top-level module under `modules/applications/emacs/`; keep Lisp and script resources alongside it. Respect import-tree discovery: any helper Nix files must be deliberately excluded or valid registration modules. Capture the integration input in the outer flake-parts closure and use the inner consumer's pkgs. Keep the shared-editor/Nixvim export unchanged. Remove the selected profile's unconditional vanilla Emacs import where Doom replaces it, rather than using broad forced overrides.

Explicit module import selects the feature, so avoid a redundant enable option. Expose only an absolute `orgDirectory`, `enableDaemon` and `enableGraphicalIntegration` in a small documented namespace. Default notes to a home-relative absolute root derived from Home Manager, with Kitsune selecting `~/notes/personal`; examples use a distinct `~/notes/work` root. Daemon support defaults on when selected; graphical integration defaults off for downstream consumers. Avoid embedding platform tests in shared Lisp.

Alternative: implement against legacy home/host paths now. Rejected because the migration removes those paths and work output; it would duplicate integration work and increase merge conflicts.

### Use a locked Unstraightened input

Prefer `marienz/nix-doom-emacs-unstraightened` with nixpkgs following the consumer-compatible root set. Preserve its transitive Doom core/modules and emacs-overlay locks rather than manually cloning Doom or running doom sync. Current upstream source exports `homeModule` and supports `programs.doom-emacs` options `doomDir`, `emacs`, `doomLocalDir`, `extraPackages`, `extraBinPackages` and `finalEmacsPackage`. It also assigns the final package to services.emacs.package. These are source observations, not a pinned compatibility result; choose and inspect the exact revision before writing configuration.

Unstraightened builds packages specified by Doom recipes/pins through Nix; declarative packages.el is permitted and is not an imperative package installation step. Use its intended package override mechanism only when required, documenting any deviation. Prefer PGTK Emacs for the Linux graphical profiles. Lock all added inputs without updating unrelated retained pins. A focused build against stable and pinned work-like unstable inputs is the compatibility gate. If incompatible, stop at that gate and propose a concrete Nix-built alternative before changing integration architecture.

Initial modules: Evil, Vertico, Doom UI/modeline, file/buffer navigation, Org with the pinned release's Org-roam integration, and Magit. Which-key and dependencies must be verified against the selected Doom version rather than guessed from historical module names. Exclude LSP, debugging and broad language bundles.

Sources inspected during exploration: https://github.com/marienz/nix-doom-emacs-unstraightened and its main/home-manager.nix and main/flake.nix. Upstream now separates doomemacs/core and doomemacs/modules. Upstream reports Linux testing and automated dependency updates; actual readiness requires the selected pin's checks and local builds.

### One user service owns the daemon

Use Home Manager's services.emacs with Unstraightened's final package and one consistent server/socket identity. Inspect the pinned Home Manager implementation before choosing unit options. Never combine service ownership with emacsclient alternate-editor auto-daemon spawning. Launch helpers use systemctl --user start, wait for client readiness with a bounded timeout, and then call the packaged emacsclient. Concurrent starts are serialised by systemd; startup errors expose the unit and journal command.

On Kitsune bind startup/shutdown to the actual UWSM graphical lifecycle and imported session environment. On WSL use on-demand service start from a shell containing the current WSLg variables. Import an explicit allowlist of display/session variables before starting; handle stale variables and validate display/socket availability rather than hard-coding DISPLAY=:0 or replacing XDG_RUNTIME_DIR blindly. For a running daemon, pass current display selection and refresh required GUI environment safely before frame creation; never restart automatically and discard buffers merely because environment values changed. Validate this behaviour on a real WSL restart before claiming it works.

When enableDaemon is false, provide ordinary Doom editing but omit daemon-dependent launch helpers and shortcuts. Graphical integration controls desktop wiring, not the availability of graphical support in the Emacs package. Missing graphics produces a clear failure. Document emacsclient -c and file opening once the service runs, systemctl --user restart emacs and journalctl diagnostics, using evaluated unit names.

### Focused external capture

Package three shell helpers with absolute executable references and safe argument handling. Pass user text/paths as arguments or correctly encoded Lisp strings, never raw Lisp concatenation. `org-capture` accepts an optional template key and otherwise shows the small template menu; `org-agenda` opens the agenda; `org-notes` opens the node finder. Mark external capture frames with a dedicated frame parameter. Use standard Org capture completion/abort hooks, adding minimal Lisp only where necessary to delete the marked frame. Test abort, failed capture and ordinary-frame captures so cleanup never deletes unrelated frames. Do not promise focus restoration beyond compositor behaviour until tested.

Choose capture and agenda shortcuts only after checking the final post-refactor bindings; document exact choices in the implementation report. Windows examples invoke these commands with wsl.exe and the correct distribution/user, without managing Windows shortcuts from Nix.

### Keep knowledge and runtime state outside configuration

Use a shallow writable root containing inbox.org, agenda/tasks.org, agenda/projects.org, roam/ and journal/. Create directories and missing target files idempotently at first use, without Nix-managed note symlinks or destructive activation templates. Generate only host-specific configuration values through Nix with proper Lisp escaping. Store Org-roam database under XDG cache and Doom runtime files under an appropriate XDG data/state directory. Backups and attachments remain user-owned; no sync settings are added.

Use standard Org capture and Org-roam capture/dailies functionality for the five templates, stable node IDs, search and backlinks. Include inbox and agenda files in agenda scope. Scientific concepts and investigations are durable nodes; meeting notes and daily observations use dated destinations. Keep templates short, without adding the later scientific/ADR suite. Preserve Babel confirmation and do not introduce automatic source-block evaluation hooks.

### Validate without activating

Reuse the refactor's stable and explicitly pinned work-like unstable fixture infrastructure, extending it with the Doom export while excluding private inputs and personal services. Inspect whether the public projection can resolve without unrelated secrets; do not assume all of the producer's flake graph is publicly resolvable. Build the final Doom package and Kitsune Home Manager activation package, then the system closure where inputs permit. Compare Neovim generated configuration against the post-refactor baseline.

Exercise startup in an isolated temporary HOME and runtime directories with networking unavailable. Account for Doom's batch/interactive initialisation differences: a bare emacs --batch that bypasses Doom is insufficient. Assert the configured Doom profile, Evil, Org and Org-roam load; test capture destinations, agenda, node links/database and daily note reuse using scratch notes. Use an isolated user-service fixture for concurrent launch/readiness/failure handling; do not start or restart the active user's Emacs service. Reserve GUI capture/focus and real WSLg lifecycle checks for documented host tests.

## Risks / Trade-offs

- Upstream Doom restructuring or package recipes break a pin -> inspect exact source and build a minimal module set before expanding.
- Daemon session variables become stale -> use explicit environment handling, actionable failures and real restart tests; avoid blanket variable replacement.
- Service/client smoke checks accidentally touch live state -> use isolated runtime directories and sockets, never the active service.
- Public feature inherits private flake dependencies -> verify the consumer fixture graph and document any unresolved access blocker.
- Refactor moves final ownership paths -> reconcile after rebase without broad formatting or unrelated changes.
- Linux build success is mistaken for WSLg verification -> report consumer build, service tests and graphical tests independently.
- Generation rollback cannot restore user data -> distinguish packaged configuration rollback from notes/database backup; never delete state to make rollback appear successful.

## Migration Plan

1. Preserve planning artifacts and rebase onto the completed migration without copying its dirty working tree or overwriting its OpenSpec configuration.
2. Add and validate the minimal locked integration and consumer fixtures (Milestone 1).
3. Add service, helpers and optional Kitsune desktop integration, validating lifecycle behaviour (Milestone 2).
4. Add minimal knowledge structure, capture/roam/dailies and scratch-data tests (Milestone 3 subset).
5. Document exact activation and manual host checks. Activation and work-repository adoption require separate user requests; neither is performed by this change.

Rollback selects the prior generation and reverts the pinned feature adoption independently. Preserve note data and runtime state, and document any cache rebuild needed for a package version change. Milestones 4 and 5 and future read-only issue/PR imports require later proposals.

# Design

## Context

See [proposal.md](proposal.md) for motivation and [the capability specs](specs/) for observable requirements. The shared Doom module already has a host-specific writable Org root, a user Emacs daemon, terminal capture helpers, repository-context knowledge capture, Org agenda, and confirmed Python/Shell/Emacs Lisp Babel execution. Work's WSL profile is a separate consumer configuration, so this repository can improve the module and its adoption guide but cannot switch that external profile.

## Goals / Non-Goals

**Goals:** Keep personal project tasks local to each configured Org root, route terminal capture to the correct repository despite a shared daemon, surface tasks in the agenda, and complete a small reproducible PDF export path.

**Non-Goals:** Writing TODO files into Git checkouts, synchronizing issue or PR state, requiring WSLg, or making Emacs a development IDE.

## Decisions

### Use Projectile project identity with an explicit terminal root

Keep Projectile as the in-Emacs project model because the user wants project capture while working inside a project. For terminal entry points, accept a repository root supplied by the caller (for example, `git rev-parse --show-toplevel`) and pass it to the daemon-side capture function. Do not infer the caller's project from the daemon's current buffer. Existing Emacs project-buffer capture can use the current Projectile project.

The upstream Org project capture package has evolved from the `org-projectile` name to `org-project-capture` and supports Projectile as a backend. During implementation, use the Nix-pinned package and its source API rather than relying on an old module name or README example; declare it and Projectile through the existing Nix/Doom package mechanism. Keep the public shell command stable if package APIs differ.

### Store sidecars under the private Org root

Derive a stable, collision-resistant project key from Git's canonical common directory (`git rev-parse --git-common-dir`) and place the project's TODO file under a dedicated directory in the configured Org root. Linked worktrees of a bare repository therefore share one task file, while independent clones remain separate. Record the common directory and a human-readable project name in file properties. Source links continue to use the active worktree root. This keeps project tasks outside commits and cross-host synchronization. Registration metadata is user data under the Org root, not generated in the Nix store. A missing checkout must not cause a task file to be silently re-associated with another repository.

### Make agenda discovery explicit and bounded

Build the agenda file set from the existing inbox and agenda files plus registered project TODO sidecars under the configured Org root. Do not recursively scan arbitrary project repositories. Add a project-only agenda command that filters to the current or explicitly supplied project file. Start with a small common state set (`TODO`, `NEXT`, `WAITING`, `DONE`, `CANCELLED`) and use Org's normal TODO semantics; avoid automatic conversion from Linear or GitHub states.

### Repair source references at capture time

Represent source references relative to the recorded repository root and include the captured commit when available. Links should use an Org link form or custom opener that resolves against the stored root, since a path relative to a note under `roam/` otherwise resolves from the wrong directory. Where a remote is available and can be normalized safely, offer a commit permalink as an additional durable reference; local paths remain useful for private or unpushed work.

### Extend the smallest existing TeX toolchain

Add only the Nix packages required by the selected Org LaTeX export path, bibliography processor, and supported document class. Prefer a narrow TeX scheme and test it against the maintained example before adding packages. Keep existing dvisvgm preview dependencies separate from PDF export dependencies. The Python figure example uses an explicitly selected project environment or the documented Nix environment, not a global interpreter. Export must not trigger Babel evaluation, and source block evaluation continues to require confirmation.

### Validate the shared module and describe consumer adoption

Test Nix evaluation/builds for the shared feature and its available local consumer(s), unit/smoke behavior for project mapping and agenda discovery, terminal-daemon integration without a display, and scientific PDF output. Document the exact input/import/options that a separate WSL consumer must adopt, preserving a private Org root and terminal-only daemon mode. Mark actual Work machine activation and graphical WSLg frames as manual/unverified unless those environments are available.

## Risks / Trade-offs

- [Project roots can move or be renamed] → Key storage by canonical root, retain the recorded root in metadata, and document an explicit re-registration/migration path rather than guessing.
- [Projectile's APIs and package naming have changed over time] → Match the pinned Nix package source and test both in-buffer and terminal entry points.
- [Agenda file discovery may become stale] → Keep a bounded registry under the Org root, ignore missing files safely, and expose a refresh/rebuild operation.
- [A full TeX installation can be large] → Start with the narrowest compatible package set and report the resulting closure size during implementation.
- [WSL daemon behavior differs by consumer lifecycle] → Exercise the terminal path with graphical variables unset and document systemd user service diagnostics; do not claim WSLg verification from headless Linux builds.

## Migration Plan

1. Add Nix package declarations and project metadata/sidecar behavior without touching existing task files.
2. Include registered project sidecars in the agenda and add capture/agenda entry points.
3. Preserve all existing notes and the current `agenda/tasks.org`; no automatic task migration is needed.
4. Add and test PDF export dependencies and the scientific example.
5. Update the shared module documentation and the separate-consumer adoption guide. For rollback, revert the configuration generation; project task files remain ordinary private Org data and are not removed.

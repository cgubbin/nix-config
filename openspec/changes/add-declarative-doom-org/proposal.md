# Proposal

## Why

Provide a reproducible Doom Emacs application for notes, tasks and technical knowledge while preserving Neovim as the development editor. Establish a reusable feature during the ongoing module refactor so personal and work configurations can adopt the same behaviour without sharing note contents.

## What Changes

- Export an explicitly selected Home Manager Doom feature with a configurable Org root, daemon and graphical integration.
- Pin Unstraightened, Doom and package dependencies through the existing flake; replace vanilla Emacs only where Doom is selected.
- Provide one systemd user daemon and `org-capture`, `org-agenda` and `org-notes` launch commands, with Hyprland integration and a documented WSLg consumer path.
- Add minimal Evil/Vertico navigation, Org agenda and capture, Org-roam backlinks and daily notes, plus basic Git integration.
- Document package maintenance, host adoption, rollback and diagnosis; validate builds and non-graphical behaviour before activation.
- Defer scientific tooling, engineering templates and external tracker synchronisation to subsequent changes. Keep Babel evaluation confirmation enabled.

## Capabilities

### New Capabilities

- `declarative-doom`: Reproducible, independently selectable Doom installation and consumer compatibility.
- `org-entrypoints`: Daemon lifecycle, graphical entrypoints and transient capture workflow.
- `org-knowledge`: Host-owned note roots, agenda, capture templates, linked knowledge and daily notes.

### Modified Capabilities

None. This worktree has no durable specifications; the ongoing refactor's host-composition requirements remain owned by that separate change.

## Impact

Implementation targets the refactored `modules/` architecture. Changes include flake inputs/lock, a feature under `modules/applications/emacs/`, public Home Manager exports, Kitsune composition, optional Hyprland bindings, consumer fixtures and documentation. Planning began at pre-refactor commit `4c929fe`; implementation was rebased onto completed migration commit `63166a5`.

The separate work repository is a downstream consumer, not an implementation target here. Work-like fixtures establish configuration compatibility; actual WSLg and work-host adoption remain explicit follow-up checks. No active environment is switched, note contents synchronised, secrets placed in the store, or Nixvim behaviour changed.

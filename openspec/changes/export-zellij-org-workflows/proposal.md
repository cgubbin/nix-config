# Proposal

## Why

Work imports the shared Doom feature but cannot receive the Org shortcuts or Catppuccin palette because Zellij configuration is currently coupled to Kitsune's internal development module. A reusable export will let Work replace its local Zellij configuration with the same Nix-managed setup and keep the terminal workflows consistent.

## What Changes

- Export a standalone Home Manager `shared-zellij` module that owns the complete Zellij KDL configuration, layouts, Ctrl-b keybindings, and Catppuccin Mocha theme.
- Refactor Kitsune's internal development feature to consume the shared module while preserving its existing `devTools.enable` gate.
- Document how a consumer imports the export and removes its conflicting local Zellij configuration.
- Add consumer evaluation/build coverage for the exported module and its Org launcher bindings.

## Capabilities

### New Capabilities

- `shared-zellij`: reusable, declarative Zellij configuration for consumers of this flake.

### Modified Capabilities

None.

## Impact

The change affects the Home Manager Zellij module, Kitsune's development composition, shared-feature documentation, and consumer fixtures. It adds no flake input. The Work repository is a separate consumer and will need to import the export and remove its prior Zellij config before regenerating and rebuilding its host.

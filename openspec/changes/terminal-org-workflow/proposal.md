# Proposal

## Why

The shared Org launchers currently create graphical frames, so a headless WSL daemon cannot open agenda or capture buffers even when the user wants to remain in the terminal. Terminal-only workflows should not depend on WSLg or a display server.

## What Changes

- Make Org launchers use an interactive terminal client when graphical integration is disabled.
- Keep the existing graphical workflow for hosts that explicitly enable graphical integration.
- Keep the client attached while agenda, capture, or note selection is active, then return to the invoking shell when the user finishes.

## Capabilities

### New Capabilities
- `terminal-org-clients`: interactive terminal-based Org agenda, capture, and note launchers backed by the managed daemon.

### Modified Capabilities

## Impact

Changes are limited to the shared Emacs launcher script and Doom entrypoints, Home Manager launcher selection, documentation, and OpenSpec specs. No package or flake input changes are expected.

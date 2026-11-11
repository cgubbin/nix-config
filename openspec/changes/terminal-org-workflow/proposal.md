# Proposal

## Why

The shared Org launchers currently create graphical frames, so a headless WSL daemon cannot open agenda or capture buffers even when the user wants to remain in the terminal. Terminal-only workflows should not depend on WSLg or a display server.

## What Changes

- Make Org launchers use an interactive terminal client when graphical integration is disabled.
- Keep the existing graphical workflow for hosts that explicitly enable graphical integration.
- Keep the client attached while agenda, capture, or note selection is active, then return to the invoking shell when the user finishes.
- Load the user's Catppuccin Mocha theme in both terminal and graphical Emacs frames using a Nix-managed package.

## Capabilities

### New Capabilities
- `terminal-org-clients`: interactive terminal-based Org agenda, capture, and note launchers backed by the managed daemon.

### Modified Capabilities

## Impact

Changes are limited to the shared Emacs launcher script and Doom configuration, Home Manager launcher selection, documentation, OpenSpec specs, and the Zellij theme selection. The Catppuccin Emacs theme is added through the existing pinned Nixpkgs package set; no flake input changes are needed.

# Design

## Context

The shared editor uses Jupytext, Quarto and Molten. Molten's image provider is disabled, the image backend is consumer-selected, and existing headless tests exercise conversion but not a full kernel/output round trip. Doom owns writable, host-specific Org roots and Org-roam metadata. The actual Windows Terminal, work project dependencies and work Claude integration are unavailable from this host.

## Goals / Non-Goals

**Goals:** Prefer existing plugins, keep project environments authoritative, make failure modes visible, and provide a realistic work-laptop validation path.

**Non-Goals:** Replace Doom or duplicate its agenda and roam database; modify work repositories or install their dependencies implicitly; claim terminal image support without an interactive test; assume direct Neotest is equivalent to Nox.

## Decisions

- Derive kernel candidates from the selected project environment and verify the kernelspec executable or supported environment-backed launch mechanism. Names alone do not prove interpreter identity. Handle uv and named Pixi activation, missing `ipykernel`, globally registered kernels, explicit overrides and unavailable environments without mutating them. Prefer native Molten/Jupyter facilities; any glue should be small and justified.
- Preserve Hydra as the main control surface and keep direct run-cell and interrupt shortcuts. Review mappings and avoid collisions. Show kernel identity and actionable errors.
- Investigate Sixel using the pinned image.nvim, Molten, ImageMagick and Zellij versions before configuring it. Test a known image in Windows Terminal outside and inside Zellij, then a Molten plot. Choose the consumer backend only after compatibility is established. Retain browser or popup fallback and Quarto Sync for unsupported rich output. Never infer the work host result from a Nix build.
- Exercise a disposable `.ipynb` with existing outputs, text and image cells through execution, save and reopen. Inspect ordering and errors in the current Jupytext/Molten save path before changing it; preserve unknown metadata and sibling files. Do not silently swallow export errors.
- Use the consumer's Org root, with quick access to existing files and a simple new note. Prefer existing editor/plugin functionality. If creating roam nodes, verify IDs and discoverability against Doom with disposable files; otherwise clearly treat quick notes as ordinary Org notes. Avoid conflicting concurrent writes between Emacs and Neovim.
- Evaluate existing work-side claudecode.nvim commands and real Python workflows as user-assisted checks. Document results without copying private code, logs, credentials or project contents into the repository; make improvements only when grounded in reproducible findings and within this change's scope.

## Risks / Trade-offs

- [Kernel metadata points elsewhere] -> Verify the launch target and expose identity; offer explicit choice instead of guessing.
- [Terminal protocols differ by version or flicker] -> Test each layer on Windows Terminal and Zellij; provide a documented fallback and record limitations.
- [Notebook round trips lose outputs or metadata] -> Use disposable fixtures and compare source, output and metadata before/after; never test destructive behavior on the user's only copy.
- [Two editors modify a note] -> Document saving and reload/conflict handling, and do not overwrite existing files.
- [Work machine unavailable] -> Keep work-host and actual Claude checks explicitly pending until the user runs them; do not mark them passed from fixtures.

## Migration Plan

Build both pinned shared-editor consumers and Kitsune without activation. Activate only after review; work adoption is a separate reviewed update of the work repo's pinned input. Keep existing note files and notebooks intact and retain the previous revision for rollback.

# Design

## Context

Doom owns writable, host-specific Org roots and Org-roam metadata. Consumers already configure the root through `knowledge.orgDirectory` (for example `/home/kit/notes/work` on the work laptop). The editor has no Org integration beyond Treesitter highlighting.

## Goals / Non-Goals

**Goals:**
- Open existing notes and create new ones from the editor in the consumer's root.
- Never guess a root or overwrite a file.

**Non-Goals:**
- Replace Doom.
- Duplicate its agenda or roam database.
- Manage concurrent edits beyond documenting them.

## Decisions

- **Root.** Read the Org root from consumer configuration. Reuse `knowledge.orgDirectory` when `shared-doom-emacs` is imported; otherwise use an explicit editor option. When unset, report how to configure it.
- **Finding and creating notes.** Use the existing picker (Telescope or snacks) over the root for finding notes. Create new notes from a minimal template with a title, using exclusive creation so an existing file is never overwritten.
- **Org-roam.** Treat quick notes as ordinary Org notes unless roam compatibility is verified. If nodes are offered, generate IDs the way Doom does and verify Doom discovers them using disposable roots.
- **Concurrent editing.** Document how Emacs and Neovim interact: save before switching, and `autoread` with checktime in Neovim.

## Risks / Trade-offs

- **[Two editors modify a note]** → Document saving and reload; never overwrite on create.
- **[Roam metadata drift]** → Do not create roam nodes until verified against Doom.

## Migration Plan

Build both pinned shared-editor consumers and Kitsune without activation. Existing notes are untouched; roll back by reverting the producer revision.

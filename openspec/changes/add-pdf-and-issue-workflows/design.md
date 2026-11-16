# Design

## Context

The shared Doom module uses a prebuilt, Nix-managed package set. Its Work/WSL mode intentionally runs Emacs as a terminal-only daemon and strips display variables from the systemd service. Zathura is already part of the shared CLI tool set, while the scientific configuration already provides Citar, a local BibTeX bibliography, Org citation support, and a paper capture template. See `proposal.md` and the delta specs for desired behavior.

Org-noter synchronizes notes with Emacs document buffers such as PDF Tools and DocView; it does not synchronize with the separate Zathura process. On WSL, retain Zathura as the reader and use explicit PDF/page references in Org notes. Graphical Emacs sessions may use Org-noter when the user chooses an Emacs-supported viewer.

## Goals / Non-Goals

**Goals:**

- Keep Org-noter, its supported PDF viewer dependencies, and Org image capture packages in the existing Nix-built Doom environment.
- Let a WSL terminal Org client open a local PDF in Zathura at a page recorded in an Org link, without restoring graphical variables in the daemon or systemd user manager.
- Improve paper and project note templates for reading papers and recording relationships to issues, pull requests, and repositories.
- Use Forge for browsing GitHub issues and pull requests from Magit; use ordinary HTTPS links for Linear, GitHub records, and portable note references.
- Keep all credentials in the user's existing Emacs auth-source or GitHub CLI credential mechanism; put neither secrets nor mutable note data in the Nix store.
- Document a repeatable paper-review workflow, project/ADR practice, and the authority boundaries between notes and external trackers.

**Non-Goals:**

- Synchronizing Org TODO state with Linear or GitHub, generating agenda entries from their APIs, or writing changes back to either service.
- Managing credentials, creating Linear/GitHub accounts, or modifying Windows shortcuts.
- Replacing Zathura with an Emacs PDF viewer on WSL.
- Requiring synchronized Org-noter behavior for terminal-only sessions.

## Decisions

### Keep the PDF reader host-appropriate

Declare `org-noter`, `pdf-tools`, and `org-download` through the existing `extraPackages` function, after verifying attributes and native dependencies in the pinned consumer package set and the stable/unstable check package sets. Configure Org-noter for graphical Emacs sessions, with local Org notes and paper files under the selected host root.

For WSL, add an Org `zathura:` link handler and a small packaged launcher that accepts a validated local PDF path and optional positive page number. Terminal Org entry points will pass the calling session's validated display environment as frame-local data; the handler will pass that environment only to the Zathura child process. It will not set or retain display variables on the daemon or systemd user manager. Use an argument vector rather than shell interpolation.

Configure image capture to write beside or beneath the current note with relative links. Avoid a global images directory shared across unrelated notes. Let the user choose where downloaded papers live, and link to those files from bibliography entries rather than copying them automatically.

Alternative considered: use PDF Tools and Org-noter as the only reader. Rejected for WSL because the established environment is terminal-only and Zathura is the user's chosen PDF application.

### Keep Linear links simple and GitHub workflow repository-aware

Represent Linear issue identifiers and URLs, GitHub issue/PR URLs, repository URL, and relevant commit metadata as ordinary Org properties and HTTPS links. A Linear link opens in the configured browser and does not call the Linear API.

Enable Forge through Doom's existing Magit module for users who want to browse GitHub issues and pull requests from a repository buffer. Use the pinned Doom package source. Authentication is optional and read from the user's configured auth-source; a missing credential must leave unauthenticated Git/Org links usable and report Forge's normal authentication error only when an authenticated Forge operation is requested.

Alternative considered: add a custom Linear client or generated read-only agenda. Deferred because the user asked for issue references and Emacs access, while issue synchronization needs a separate definition of refresh, ownership, and conflict behavior.

### Write the workflows around existing capture and ownership boundaries

Extend the paper template with citation key, title/DOI, local PDF, research question, key claims, evidence, limitations, methods, and related notes. Extend project and investigation templates with repository, Linear/GitHub links, decisions, investigations, and benchmark links. Keep action items in project or personal TODO sidecars; project overview and meeting notes remain documentation, not a second task database.

Update `docs/emacs-org.md` with keyboard and terminal workflows for paper capture, Citar/BibTeX lookup, PDF page references, Zathura launch, image capture, Org-noter on graphical Emacs, Forge, and Linear/GitHub links. Clarify how WSL differs from graphical hosts and document the required credential location without including any secret values.

## Risks / Trade-offs

- [Pinned package sets may lack or rename one requested Emacs package] → Check package availability on stable and unstable before implementation; use only package overrides pinned through the existing flake if needed, and do not fall back to Doom package downloads.
- [WSLg display state may be absent or stale when a terminal client opens a Zathura link] → Validate socket paths at the shell boundary, pass them only to that child, and return a short actionable error when no display is available; retain manual `zathura FILE --page PAGE` as a shell fallback.
- [Forge needs a host credential for authenticated GitHub API operations] → Keep all credentials in existing auth-source or `gh` credential storage, document the optional setup, and test that profile derivations contain no credential material.
- [Readers may assume Org-noter synchronizes with Zathura] → State prominently in docs that Org-noter runs only with supported Emacs PDF viewers; WSL annotations are explicit page-linked Org text, not live synchronized annotations.
- [Captured figures can grow the notes tree] → Use relative, per-note assets and explain that image files are ordinary writable data included in note backups.

## Migration Plan

1. Verify package availability and native PDF build dependencies against pinned package sets; update the Doom profile and package checks.
2. Add safe Zathura page links for terminal WSL clients and graphical-only Org-noter configuration, with tests covering paths/pages and absent display state.
3. Improve capture templates and add external issue/PR properties, links, and Forge support without changing existing note files or task ownership.
4. Add focused documentation and package/link smoke tests, then build both stable and unstable Home Manager Doom profiles.
5. Roll back by reverting the Nix configuration generation. Existing notes, PDFs, and image assets remain ordinary user data and are not deleted.

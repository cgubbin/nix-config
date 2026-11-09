# Tasks

## 1. Baseline and draft reconciliation

- [x] 1.1 Review the uncommitted foundation and dashboard/science spike, preserve all existing changes, and record the initial `pkgs.dvisvgm` evaluation failure and exact baseline commands in a validation report.
- [x] 1.2 Inspect stable and work-like unstable pinned nixpkgs for the supported TeX and SVG renderer attributes; replace the invalid draft dependency and verify both consumer configurations evaluate without changing unrelated lock nodes.

## 2. Dashboard

- [x] 2.1 Enable and configure Doom's built-in dashboard with a graphical banner, readable terminal fallback and capture/agenda/notes/journal actions; verify the rendered menu and each action in an isolated session, including fonts or a text-only fallback.
- [x] 2.2 Extend the disposable VM and terminal startup checks to verify the dashboard on a new frame and ensure external capture finalise/abort still close only the capture frame; document shortcuts and the manual Wayland focus check.

## 3. Equations, figures and citations

- [x] 3.1 Supply a small Nix-managed TeX/renderer set and verify real inline and display equation image creation and regeneration in an isolated build; report closure impact and missing optional PDF-export dependencies.
- [x] 3.2 Configure image previews, relative figure links and writable attachments; verify a linked image previews and HTML export retains figure/PDF links, then document locations and commands.
- [x] 3.3 Install Citar through Nix and configure per-root bibliography, citation insertion/following and local paper paths without overwriting user data; verify synthetic reference lookup, insertion, paper resolution and HTML citation/bibliography output.

## 4. Safe calculations and scientific notes

- [x] 4.1 Configure or verify built-in Python, shell and Emacs Lisp Babel backends; test that opening and HTML-exporting a document with side-effecting blocks executes none of them.
- [x] 4.2 Verify an actual execution request prompts after Doom's lazy Org initialization, and that refusing it prevents the side effect; test confirmed execution separately and retain the protection across startup paths.
- [x] 4.3 Support documented per-block or per-notebook interpreter selection for project environments without changing the global Python command; test Python execution using distinct isolated interpreters and verify practical uv/Pixi command invocation without downloading dependencies.
- [x] 4.4 Add five distinct Org-roam scientific templates with useful assumptions, method/derivation, validation, references and related-concept prompts; create each in scratch storage and verify stable IDs and existing templates remain available.
- [x] 4.5 Document preview regeneration, Babel confirmation, safe interpreter selection, uv/Pixi examples, relative figures, local papers and citation commands; check examples against the tested configurations.

## 5. Reproducible example and integration

- [x] 5.1 Add a self-contained example derivation, second linked Org-roam node and synthetic bibliography; run its explicitly confirmed Python block in scratch storage to generate a deterministic figure and verify the link and citation resolve.
- [x] 5.2 Render the example's inline and display equations and export HTML without implicit code execution; verify the rendered equation files, figure reference, citation and scientific content in the output.
- [x] 5.3 Run formatting/lint, flake evaluation, stable/unstable consumer builds, the offline startup and knowledge checks, and the disposable session VM; build the Kitsune Home Manager/system closure without activating it and record exact results and any blockers.
- [x] 5.4 Review the final diff for unchanged Nixvim, no secrets or personal notes in the store and unchanged unrelated pins; document exact activation and manual Kitsune/WSLg verification commands and explicitly label untested graphical or work-host behaviour.

## Workflow follow-up

- Review and archive or sync the completed foundation and this change in dependency order; preserve both sets of capability specs.
- Activate only on a separate explicit request and verify actual Hyprland/Wayland behaviour.
- Adopt in the separately owned work repository on a separate request and test real WSLg startup and restart.
- Propose engineering project/ADR templates and repository-aware capture separately; design any future Linear/GitHub imports with clear ownership before implementing synchronisation.

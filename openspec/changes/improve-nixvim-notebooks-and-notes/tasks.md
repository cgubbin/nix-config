# Tasks

## 1. Project kernels and controls

- [ ] 1.1 Inspect pinned Molten and Jupyter capabilities, implement project-aware kernel selection and identity display; verify single, multiple, missing, stale and explicitly selected kernels without dependency installation.
- [ ] 1.2 Exercise uv and named Pixi environment activation and misleading global kernels using disposable fixtures; verify the launched kernel reports the intended `sys.executable` and environment.
- [ ] 1.3 Consolidate notebook controls around the Hydra, retaining direct run-cell and interrupt actions; verify mappings and document the resulting menu.

## 2. Notebook outputs

- [ ] 2.1 Determine pinned image.nvim, Molten, ImageMagick and Zellij support; document a Windows Terminal Sixel test outside and inside Zellij, including version collection and a fallback.
- [ ] 2.2 Configure a consumer-appropriate image provider where supported and verify text and plot output in an interactive notebook; record work-host results and unsupported cases without claiming headless proof.
- [ ] 2.3 Investigate output import/export and save ordering, then preserve cells, metadata, pre-existing and new outputs with visible errors; verify a disposable notebook save/reopen round trip including a sibling Markdown file.

## 3. Quick Org notes

- [ ] 3.1 Add consumer-configured access to existing notes and creation of ordinary Org notes, avoiding guessed roots and overwrites; verify two isolated roots, missing configuration and collisions.
- [ ] 3.2 Verify disposable notes remain editable in Doom and document concurrent editing; if advertising roam nodes, verify stable IDs and Doom discovery rather than assuming compatibility.

## 4. Work-host workflow evaluation

- [ ] 4.1 On the work laptop, validate a real uv and Pixi project, Just/Nox tasks, direct tests/debugging, notebook kernel and text/plot/save round trips; record sanitized outcomes and unresolved failures without copying private project data.
- [ ] 4.2 On the work laptop, verify the existing Claude extension starts, sends selection/file context, shows a diff and accepts or rejects it; document Zellij, logging and version issues and targeted improvements supported by evidence.
- [ ] 4.3 Document how to adopt the reviewed shared revision in the separate work repo, including rollback; verify actual work activation separately and preserve existing local changes.

## 5. Integrated validation

- [ ] 5.1 Run relevant automated checks for both pinned consumers and a non-activating Kitsune build; document interactive work-host checks independently and retain pending status until actually performed.

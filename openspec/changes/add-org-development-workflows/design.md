# Design

Org-roam remains the store for durable engineering knowledge. Its templates add four lightweight document shapes: project overview, investigation, benchmark, and ADR. The existing Org agenda and `agenda/tasks.org` remain the sole local source for actionable commitments; project notes can link to tasks and to external Linear/GitHub records without importing their state.

`org-project-capture` gathers repository root, branch, and commit with Git at invocation time. Optional file and line arguments (or `NVIM_FILE` and `NVIM_LINE`) provide a source reference. The launcher passes this context in frame parameters for terminal clients or the existing JSON request for graphical clients, avoiding mutable daemon-wide environment changes. The capture template records the metadata in the resulting note. Calls outside a Git repository still produce a note with the working directory and empty revision fields.

The command creates a technical note in the host-configured Org-roam root, preserving personal/work separation. It does not create project-local files, execute repository code, or synchronize issues.

The pinned nixpkgs package set contains `org-projectile` version `20260313.1738`. Its documented integration creates TODOs associated with Projectile projects. It is deferred because the current Doom configuration does not enable Projectile, and adopting it would require choosing whether project TODOs are merely views into the central agenda or a second project-scoped task store. The initial workflow uses Org-roam project notes and the existing central agenda instead.

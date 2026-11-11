# Add Org software-development workflows

Provide reusable Org-roam templates for project overviews, engineering investigations, benchmark reports, and architecture decision records. Add an `org-project-capture` command that attaches repository, branch, commit, and optional source file/line metadata to a new engineering note.

## Motivation

The existing Org setup supports personal agenda tasks and durable knowledge notes, but lacks consistent software project documentation. Project tasks must continue to use the existing `agenda/tasks.org` source so Org does not compete with Linear or GitHub issue state.

## Scope

- Add small Org-roam templates for project overview, investigation, benchmark, and ADR notes.
- Add a packaged repository-aware capture command.
- Document how project notes relate to the existing agenda and external issue trackers.
- Evaluate `org-projectile`; keep it out of this implementation unless it fits the existing package and task model without introducing another task store.

## Out of scope

- Linear or GitHub synchronization or write-back.
- Automatic modification or scanning of source repositories.
- A separate project task database.

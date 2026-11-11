## ADDED Requirements

### Requirement: Engineering knowledge templates
The application SHALL provide Org-roam templates for project overviews, engineering investigations, benchmark reports, and architecture decision records.

#### Scenario: Create an engineering note
- **WHEN** a user invokes Org-roam capture and selects one of these templates
- **THEN** a note with the corresponding useful sections is created in the configured Org-roam directory

### Requirement: Repository-aware capture
The application SHALL provide a command that creates an engineering note containing the current repository root, branch, and commit when available, and may include a source file and line supplied by the caller.

#### Scenario: Capture from a repository
- **WHEN** `org-project-capture` is run in a Git checkout
- **THEN** the resulting note records repository and revision metadata without changing repository files

#### Scenario: Capture without a repository
- **WHEN** `org-project-capture` is run outside a Git checkout
- **THEN** it still opens a note and records the working directory with unavailable revision fields left empty

### Requirement: Single local task source
Project documentation SHALL use the existing Org agenda task file for local actionable tasks and SHALL NOT create or synchronize a second task database.

#### Scenario: Plan work for a project
- **WHEN** a user records an actionable commitment for a project
- **THEN** it remains an Org agenda task and can link to the project note or external issue

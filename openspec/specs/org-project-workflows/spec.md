# Org Project Workflows Specification

## Purpose

Provide private, repository-aware project task and engineering note workflows that remain usable from Emacs, Neovim, and terminal multiplexers across separate host Org roots.

## Requirements

### Requirement: Private project task storage
The system SHALL store project TODOs under the configured host Org root and SHALL NOT write task files into project repositories.

#### Scenario: Capture a task for a project
- **WHEN** a user captures a project task for a recognized repository
- **THEN** the task is stored in a project-specific Org file beneath that host's configured Org root

#### Scenario: Same repository name on separate hosts
- **WHEN** personal and work hosts use repositories with the same directory name
- **THEN** their project task files remain separate within their independently configured Org roots

#### Scenario: Multiple linked worktrees for one bare repository
- **WHEN** a user captures tasks from different linked worktrees of the same Git common directory
- **THEN** those worktrees use the same private project task file while source references use the active worktree

#### Scenario: Capture outside a repository
- **WHEN** a user requests project task capture without a repository context
- **THEN** the workflow reports that project context is unavailable and does not create a misleading project task file

### Requirement: Project context from terminal callers
The system SHALL accept an explicit repository root from terminal callers so project capture does not depend on the Emacs daemon's current buffer.

#### Scenario: Capture from Neovim or Zellij
- **WHEN** a caller supplies the current Git repository root to the project capture command
- **THEN** Emacs captures the task for that repository even if its current buffer belongs to another project

#### Scenario: Capture from an Emacs project buffer
- **WHEN** a user invokes project capture inside a recognized project buffer without an explicit root
- **THEN** the task is associated with the current project

#### Scenario: Invalid explicit root
- **WHEN** a caller supplies a path that is not a valid project root
- **THEN** the command reports the invalid context and leaves project task files unchanged

### Requirement: Agenda discovery of project tasks
The system SHALL include valid project task files beneath the host Org root in its Org agenda without scanning unrelated source repositories.

#### Scenario: Global agenda includes project tasks
- **WHEN** the user opens the global Org agenda
- **THEN** actionable TODOs from registered project task files appear alongside the host's existing agenda files

#### Scenario: Project-specific agenda
- **WHEN** the user requests an agenda for the current project
- **THEN** the view contains tasks associated with that project only

#### Scenario: Project task file is removed
- **WHEN** a previously registered project task file no longer exists
- **THEN** agenda generation skips it without failing or searching the project repository

### Requirement: Personal task ownership
Project TODOs SHALL represent personal commitments and SHALL NOT be synchronized as competing copies of Linear issues or GitHub state.

#### Scenario: Link a task to an external issue
- **WHEN** a project task refers to a Linear issue or GitHub pull request
- **THEN** the Org task may retain a URL or identifier while the external service remains authoritative for shared status

### Requirement: Durable engineering source references
Repository-aware engineering notes SHALL record usable source references that identify the repository and, when available, a stable revision.

#### Scenario: Capture a source file and line
- **WHEN** an engineering note is captured with a source path and line from a repository
- **THEN** its source link resolves relative to the repository root recorded in that note

#### Scenario: Capture a committed source reference
- **WHEN** the repository has a commit and a source file is supplied
- **THEN** the note records enough repository, commit, path, and line information to construct a durable commit-based permalink

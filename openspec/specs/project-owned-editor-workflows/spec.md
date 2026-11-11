# project-owned-editor-workflows Specification

## Purpose

Keep editor tasks and Python tooling aligned with project-owned workflows and their selected environments.

## Requirements

### Requirement: Discover and run project tasks
The editor SHALL expose actual project Just recipes as explicit tasks in the approved project environment, accepting recipe arguments without assuming recipe names.

#### Scenario: Project exposes different recipes
- **WHEN** two projects define different recipe names
- **THEN** each task picker displays its own available recipes and runs the selected recipe from its project root

#### Scenario: Discovery fails
- **WHEN** Just or the project configuration is unavailable or invalid
- **THEN** the editor reports an actionable error without silently running another command

### Requirement: Distinguish Nox and direct Python workflows
The editor SHALL make project-owned Just/Nox runs available and label direct test and debug actions with their selected interpreter; it SHALL NOT claim direct execution is equivalent to a Nox session without a project-defined integration.

#### Scenario: Isolated session
- **WHEN** a Just recipe invokes a Nox session using its lockfile
- **THEN** the task executes that project-owned recipe and preserves its session setup and outcome

### Requirement: Explicit Python environment selection
The editor SHALL provide visible, project-scoped selection of executable uv virtual environments or named Pixi environments and SHALL report unavailable choices without silently switching to unrelated Python.

#### Scenario: Named Pixi environment
- **WHEN** the user selects a non-default Pixi environment
- **THEN** subsequent supported editor subprocesses for that project use the selected environment or report why it is unavailable

### Requirement: Python tools use a coherent environment
Python language-server, lint, formatting, test and debug integrations SHALL expose their environment and use the selected project environment where supported, with limitations reported rather than hidden.

#### Scenario: Change project environment
- **WHEN** the user changes a project's Python environment
- **THEN** subsequent tools use the updated selection and existing language servers can be restarted to apply it

#### Scenario: Lint tools use a separate dependency group
- **WHEN** Ruff is available in a separate existing lint environment
- **THEN** the user can select that environment for live Ruff diagnostics and formatting independently of the environment used for direct tests and debugging

### Requirement: No automatic project mutation
Discovery and editor startup SHALL NOT install dependencies, synchronize lockfiles or execute project tasks implicitly.

#### Scenario: Environment needs preparation
- **WHEN** an environment is missing or stale
- **THEN** the editor reports the problem and leaves preparation to an explicit project command

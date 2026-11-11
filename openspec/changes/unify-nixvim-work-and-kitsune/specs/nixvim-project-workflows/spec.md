## Purpose

Keep editor project environments, Python tools and notebook creation predictable and safe across both supported machines.

## ADDED Requirements

### Requirement: Project environments are isolated
Project-specific editor subprocesses SHALL receive the selected project's approved environment without retaining variables from a previously visited project. Failed or unapproved environment loads SHALL be reported and retryable.

#### Scenario: Switch projects and return
- **WHEN** the user visits Python or Rust projects A, B and then A in one editor session
- **THEN** each project's test and debug subprocesses receive its own environment, including removals, without leaking the other project's variables

#### Scenario: Environment load fails then succeeds
- **WHEN** direnv is unavailable, unapproved or fails and the user subsequently fixes it
- **THEN** a clear diagnostic is available and the editor can retry without restarting

### Requirement: Python interpreter selection has reliable fallbacks
Python testing and debugging SHALL select a valid project interpreter using the work baseline's Pixi and virtual-environment support with a documented fallback when a tool, manifest or interpreter is unavailable. Resolution SHALL not leave permanent in-progress state after an error.

#### Scenario: Pixi unavailable
- **WHEN** a project has a pyproject.toml but Pixi is not installed or the file is not a Pixi project
- **THEN** interpreter resolution falls back to an executable project virtual environment or available Python and reports failure if neither exists

#### Scenario: Environment changes
- **WHEN** a project's environment changes or a resolution fails
- **THEN** the user can refresh the result and subsequent test and debug runs select the current interpreter

### Requirement: Test runner arguments reflect installed capabilities
Python test execution SHALL work with a pytest-only project and SHALL NOT require pytest-xdist solely to disable parallel workers.

#### Scenario: Run tests without xdist
- **WHEN** the project provides pytest but not pytest-xdist
- **THEN** the editor runs the selected tests without passing unsupported xdist options

### Requirement: Notebook creation protects existing files
Creating a notebook SHALL NOT overwrite an existing notebook without an explicit user confirmation.

#### Scenario: Notebook already exists
- **WHEN** a user requests a new notebook at an existing path
- **THEN** the existing file remains unchanged unless the user explicitly confirms replacement

#### Scenario: New notebook path
- **WHEN** a user requests a new notebook at an unused path
- **THEN** a valid notebook is created and opened

#### Scenario: Notebook conversion with a neighboring Markdown file
- **WHEN** a notebook is opened, saved, or closed while a Markdown file with the same base name exists
- **THEN** conversion uses an isolated temporary file and the neighboring Markdown file is neither read as notebook content nor modified or removed

### Requirement: Completion and navigation are consumer-aware
Completion SHALL use one coherent source configuration with no uninstalled source registrations; the editor-configuration shortcut SHALL resolve to a consumer-configurable existing location.

#### Scenario: Open completion and editor configuration
- **WHEN** a user opens completion or invokes the editor-configuration shortcut
- **THEN** configured sources are available without duplicate entries and the shortcut targets the consumer's selected path

### Requirement: Notebook and debugging integrations remain usable
The shared editor SHALL support the newer work configuration's DAP, Neotest and Quarto/Molten workflows with explicitly supplied optional dependencies and consumer-specific integrations.

#### Scenario: Work-like project exercises integrations
- **WHEN** a supported consumer opens a representative Python project and Quarto document with the documented tools installed
- **THEN** test discovery and execution, debugger startup, notebook creation and preview work without duplicate initialization

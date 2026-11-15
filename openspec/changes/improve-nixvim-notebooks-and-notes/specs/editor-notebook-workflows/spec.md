# Spec Delta

## Purpose

Support reliable project-aware notebook execution and output inspection in the shared editor.

## ADDED Requirements

### Requirement: Select project kernel safely
The editor SHALL identify and start an unambiguous kernel belonging to the selected project environment, offer explicit selection when ambiguous, and report unavailable kernels without installing dependencies or silently selecting an unrelated environment.

#### Scenario: One matching kernel
- **WHEN** a notebook is started with exactly one verified matching project kernel
- **THEN** the editor starts that kernel and displays its identity

#### Scenario: Multiple or no matching kernels
- **WHEN** matching kernels are ambiguous or unavailable
- **THEN** the editor requests a choice or reports an actionable error without silently starting an unrelated kernel

#### Scenario: Explicit selection
- **WHEN** the user deliberately selects another available kernel
- **THEN** the editor uses that choice and makes its identity visible

### Requirement: Notebook control menu
The editor SHALL provide a discoverable notebook menu for execution, kernel management and output inspection, with direct shortcuts for frequent operations.

#### Scenario: Run and interrupt
- **WHEN** the user opens the notebook menu
- **THEN** the available actions include running cells and interrupting or restarting the kernel

### Requirement: Inspect notebook output
The editor SHALL display text output and provide an explicit image rendering mode or actionable fallback suitable for the consumer terminal.

#### Scenario: Supported image rendering
- **WHEN** a supported terminal and multiplexer display a notebook plot
- **THEN** the user can inspect the plot without a separate Quarto preview

#### Scenario: Unsupported rendering
- **WHEN** inline images are unavailable
- **THEN** the user can discover the limitation and a documented way to inspect the image

### Requirement: Preserve notebook data
The editor SHALL preserve notebook cells, metadata and existing outputs when saving unless an explicit user action changes them, and SHALL surface save or export failures.

#### Scenario: Save and reopen
- **WHEN** a user edits and saves a notebook containing text and image outputs and reopens it
- **THEN** intended changes and retained outputs are present and unrelated content remains intact

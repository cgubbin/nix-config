# Spec Delta

## Purpose

Run notebooks in the project's own environment and inspect their output inside the shared editor.

## ADDED Requirements

### Requirement: Start kernels in the project environment
The editor SHALL start notebook kernels using the interpreter of the selected project environment, scoped to the project root or worktree, with the project's captured environment variables, and SHALL NOT write kernel registrations to the project or the user's Jupyter data directory.

#### Scenario: Unambiguous project environment
- **WHEN** a notebook is opened in a project with exactly one selected or discoverable environment that contains `ipykernel`
- **THEN** the editor starts a kernel using that environment's interpreter and displays the kernel's identity, including its executable

#### Scenario: Separate worktrees
- **WHEN** notebooks are opened in two worktrees of the same project, each with its own environment
- **THEN** each notebook runs in a kernel using its own worktree's interpreter

#### Scenario: Ambiguous environment
- **WHEN** a project has several candidate environments and none is selected
- **THEN** the editor asks the user to choose rather than starting a kernel

#### Scenario: Kernel cannot start
- **WHEN** the environment lacks `ipykernel`, its direnv environment is not approved, or it is unavailable
- **THEN** the editor reports the problem with the command that would prepare it, and does not start a kernel from an unrelated interpreter

### Requirement: Percent-format notebooks
The editor SHALL execute `# %%` cells in Python files directly, including running the current cell and advancing to the next, and SHALL NOT write paired notebook files implicitly.

#### Scenario: Run and advance
- **WHEN** the user runs the current cell with the run-and-advance action
- **THEN** the cell is executed and the cursor moves to the next cell

#### Scenario: Save a percent-format notebook
- **WHEN** the user saves a `# %%` Python file
- **THEN** only that file is written

### Requirement: Inline notebook output
The editor SHALL display text output and SHALL render image output inline using the consumer-selected image backend, with a documented fallback when inline images are unavailable.

#### Scenario: Supported terminal
- **WHEN** a plot is produced in a terminal and multiplexer supported by the configured backend
- **THEN** the plot is displayed in the editor without a separate preview

#### Scenario: Unsupported rendering
- **WHEN** inline images cannot be displayed
- **THEN** the user can discover the limitation and open the output by a documented alternative

### Requirement: Preserve notebook data
The editor SHALL preserve notebook cells, metadata and existing outputs when saving `.ipynb` files unless the user changes them, SHALL show outputs already stored in a notebook when it is opened, and SHALL surface save or export failures.

#### Scenario: Save and reopen
- **WHEN** a user edits and saves an `.ipynb` containing text, image and error outputs and reopens it
- **THEN** intended changes and retained outputs are present and unrelated content remains intact

#### Scenario: Export failure
- **WHEN** writing outputs to a notebook fails
- **THEN** the editor reports the failure instead of silently continuing

### Requirement: Notebook control menu
The editor SHALL provide a single discoverable notebook menu for execution, kernel management and output inspection, with direct shortcuts only for running a cell and interrupting the kernel, and without duplicate mappings for the same action.

#### Scenario: Open the menu
- **WHEN** the user opens the notebook menu
- **THEN** it offers run-and-advance, run line, run above, run all, re-evaluate, show or hide output, open in browser, kernel selection, interrupt and restart

### Requirement: Temporary document rendering
The editor SHALL render the current document with Quarto into a location outside the project and open the result, without requiring the user to supply an output path.

#### Scenario: Render a notebook for viewing
- **WHEN** the user invokes the render command on a notebook or Quarto document
- **THEN** the rendered output opens in the browser and no rendering artefacts are created inside the repository

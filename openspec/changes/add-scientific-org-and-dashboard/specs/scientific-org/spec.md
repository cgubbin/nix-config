## Purpose

Support scientific writing and reproducible calculations in portable Org notes with declaratively managed dependencies and explicit evaluation control.

## ADDED Requirements

### Requirement: Equation previews
The environment SHALL provide Nix-managed tools to render inline and display LaTeX fragments and regenerate previews after edits, without requiring an independently installed TeX distribution.

#### Scenario: Render and refresh equations
- **WHEN** a user previews a note containing inline and display equations and changes an equation
- **THEN** the environment generates a readable preview and can regenerate it for the changed expression

### Requirement: Explicit execution consent
Opening or exporting an Org document SHALL NOT execute embedded code automatically. Interactive execution SHALL require user confirmation unless the user explicitly defines a narrower trusted policy.

#### Scenario: Open and export untrusted content
- **WHEN** a document contains a source block with a side effect and the user opens or exports it
- **THEN** the side effect does not occur without explicit execution and confirmation

#### Scenario: Decline execution
- **WHEN** the user declines the confirmation for a source block
- **THEN** the source block does not run

### Requirement: Project-specific calculations
Org Babel SHALL support Python, shell and Emacs Lisp and allow a notebook or block to select its own Python command or project environment without setting one global scientific interpreter.

#### Scenario: Select an environment for a block
- **WHEN** a user explicitly configures a Python block to run in its uv or Pixi project environment and confirms execution
- **THEN** that block uses the selected environment without changing other notebooks' interpreter choices

### Requirement: Scientific citations
The environment SHALL provide citation lookup, insertion and opening against a user-controlled BibTeX bibliography and optional local papers, with paths configurable independently for each Org root.

#### Scenario: Cite a local reference
- **WHEN** the user adds a BibTeX entry and inserts a citation into an Org note
- **THEN** the citation resolves against the configured bibliography and a linked local paper can be opened when present

### Requirement: Figures and attachments
Users SHALL be able to preview linked images and retain relative links to figures and attached PDFs in writable note storage. Export SHALL preserve usable links to those files.

#### Scenario: Reference a generated figure
- **WHEN** a confirmed calculation generates a figure beside the note and the user exports the note to HTML
- **THEN** the resulting HTML contains a usable relative reference to the figure

### Requirement: Scientific note templates
The environment SHALL offer distinct, extensible note templates for physics concepts, mathematical derivations, algorithms, papers and numerical experiments.

#### Scenario: Create a derivation note
- **WHEN** a user selects the mathematical derivation template
- **THEN** the new note includes space for assumptions, derivation, validation, references and related concepts without a manual path choice

### Requirement: Demonstrable export
The repository SHALL provide a reproducible example containing a derivation, rendered LaTeX, confirmed Python execution, a generated figure, a bibliography citation and an Org-roam link. It SHALL be tested through HTML export.

#### Scenario: Verify the example
- **WHEN** the example is copied to an isolated writable directory, its chosen calculation is confirmed and run, its equations rendered and its document exported
- **THEN** the figure and equation preview exist, the citation and related-node link resolve, and the resulting HTML contains the expected scientific content

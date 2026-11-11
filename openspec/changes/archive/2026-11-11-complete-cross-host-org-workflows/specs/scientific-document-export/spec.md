# Spec Delta

## Purpose

Enable reproducible scientific Org documents to produce shareable PDF output with citations, figures, and mathematical notation using dependencies supplied by Nix.

## ADDED Requirements

### Requirement: Declarative PDF export dependencies
The configured environment SHALL provide the documented dependencies required to export supported scientific Org documents to PDF without imperative package installation.

#### Scenario: Export on a configured host
- **WHEN** a user exports a supported scientific Org document to PDF
- **THEN** the configured Nix environment supplies the required exporter and TeX dependencies

#### Scenario: Rebuild the environment
- **WHEN** the user rebuilds or rolls back the Nix configuration
- **THEN** the PDF export toolchain follows that selected reproducible generation

### Requirement: Scientific document fidelity
PDF export SHALL preserve the document's mathematical notation, citations, and linked local figures for the supported example workflow.

#### Scenario: Export the scientific example
- **WHEN** the user exports the maintained scientific example
- **THEN** the resulting PDF contains its rendered equations, bibliography references, and generated figure

### Requirement: Safe source block evaluation
Adding PDF export SHALL preserve the existing policy that opening or exporting an Org document does not silently execute its source blocks.

#### Scenario: Export a document with executable blocks
- **WHEN** a user exports an Org document containing source blocks
- **THEN** export does not execute those blocks implicitly

#### Scenario: Explicitly evaluate a source block
- **WHEN** a user explicitly evaluates a source block
- **THEN** the configured confirmation policy remains in effect for untrusted code

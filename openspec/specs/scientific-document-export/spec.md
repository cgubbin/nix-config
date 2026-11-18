# Scientific Document Export Specification

## Purpose

Enable reproducible scientific Org documents to produce shareable PDF output with citations, figures, and mathematical notation using dependencies supplied by Nix.

## Requirements

### Requirement: Declarative PDF export dependencies
The configured environment SHALL provide the dependencies required to export any Org document that uses Org's default LaTeX header, including its fonts, to PDF without imperative package installation or document-specific LaTeX headers.

#### Scenario: Export on a configured host
- **WHEN** a user exports a supported scientific Org document to PDF
- **THEN** the configured Nix environment supplies the required exporter and TeX dependencies

#### Scenario: Rebuild the environment
- **WHEN** the user rebuilds or rolls back the Nix configuration
- **THEN** the PDF export toolchain follows that selected reproducible generation

#### Scenario: Export a note with no LaTeX headers
- **WHEN** a user exports an Org note that has no `#+latex_header` or `#+latex_class` lines and contains display maths, inline maths and a citation
- **THEN** a PDF is produced, typeset in Latin Modern, with the maths rendered and the citation resolved

#### Scenario: Document that already loads lmodern
- **WHEN** a document such as the maintained scientific example loads `lmodern` itself and is exported
- **THEN** export still succeeds

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

### Requirement: Greek letters in exported text
Greek letters written as Unicode characters in an exported document's plain text SHALL be typeset as the corresponding mathematical Greek symbols, without export errors. Other unsupported characters SHALL be reported, not dropped silently.

#### Scenario: Greek letter in prose
- **WHEN** a note whose prose contains "ε varies in space" and "χ(ω)" is exported to PDF
- **THEN** a PDF is produced, and ε and χ appear as the Greek symbols

#### Scenario: Equation previews
- **WHEN** the user previews a LaTeX fragment in a graphical frame of a note containing Unicode Greek in its text
- **THEN** the preview is generated without errors

#### Scenario: Character outside the mapped set
- **WHEN** an exported note contains a Unicode character in its text that is neither mapped nor supported by the default fonts
- **THEN** a PDF is still produced, without that character; Org reports that the PDF was produced with warnings that name the character and its code point (e.g. "∇ (U+2207)"); and the documentation says how to write it instead

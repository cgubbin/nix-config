# Spec Delta

## Purpose

Support focused reading of local technical papers with notes and figures stored alongside the user's private Org knowledge base.

## ADDED Requirements

### Requirement: Page-linked PDF reading notes
The configured environment SHALL let a user keep Org notes linked to page locations in local PDFs viewed with Zathura.

#### Scenario: Open a cited PDF at a noted page
- **WHEN** a user follows a PDF/page reference from a paper note on a terminal-first host
- **THEN** Zathura opens the local PDF at the referenced page and the Org note remains editable in the terminal

#### Scenario: Add an annotation at a page
- **WHEN** a user records a finding while reading a PDF
- **THEN** the Org note stores the page reference and the finding as writable Org content

#### Scenario: Keep host notes private
- **WHEN** a user annotates a paper on a configured host
- **THEN** the Org note and any user-managed paper copy remain under that host's chosen notes or bibliography location

#### Scenario: Use synchronized Org-noter sessions
- **WHEN** a user chooses a graphical Emacs PDF-reading session
- **THEN** Org-noter can keep notes synchronized with the document through a supported Emacs PDF viewer

### Requirement: Portable figure capture
The configured Org environment SHALL let users capture an image into a writable location and insert a relative Org link to it.

#### Scenario: Capture a figure into a note
- **WHEN** a user inserts an image from a local file, clipboard, or screenshot into an Org note
- **THEN** the image is stored in a writable note asset location and the note links to it relatively

#### Scenario: Export a note with a captured figure
- **WHEN** a user exports a note containing a captured figure
- **THEN** the relative figure link resolves from the note tree without requiring a machine-specific absolute path

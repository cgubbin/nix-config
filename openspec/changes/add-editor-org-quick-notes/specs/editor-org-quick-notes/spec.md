# Spec Delta

## Purpose

Enable quick editing and creation of Org notes while preserving existing Doom workflows.

## ADDED Requirements

### Requirement: Access the consumer's Org notes
The editor SHALL allow users to open existing Org notes and create quick notes within the consumer's configured writable Org root.

#### Scenario: Personal and work roots
- **WHEN** different consumers configure different Org roots
- **THEN** each editor offers access to its own root without exposing or writing to the other consumer's root

#### Scenario: Missing configuration
- **WHEN** no Org root is configured
- **THEN** the editor reports how to configure it without creating a guessed notes directory

### Requirement: Preserve compatibility with Doom
Quick notes SHALL remain ordinary Org files and SHALL preserve existing content and metadata; notes advertised as Org-roam nodes SHALL use compatible stable IDs and be discoverable by the existing Doom workflow.

#### Scenario: Open a quick note in Doom
- **WHEN** a user saves a quick note and opens it with Doom
- **THEN** its text and intended Org structure are preserved

#### Scenario: Existing file collision
- **WHEN** creating a quick note would overwrite an existing file
- **THEN** the editor preserves the existing file and offers an actionable choice

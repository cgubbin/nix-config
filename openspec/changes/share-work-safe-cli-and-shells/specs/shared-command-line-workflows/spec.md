# Spec Delta

## Purpose

Share command-line workflows across consumers while keeping history and host-specific configuration under consumer control.

## ADDED Requirements

### Requirement: Independent command-line features
Consumers SHALL be able to select common CLI tools independently of personal-only features, using their own package set and without importing host identities or secrets.

#### Scenario: Work baseline
- **WHEN** the work consumer imports the common CLI baseline
- **THEN** it receives the documented common tools without enabling Atuin or a command-history synchronization service

#### Scenario: Personal selection
- **WHEN** the personal consumer selects its existing optional features
- **THEN** its explicitly selected history and CLI behavior remains available

### Requirement: Local work history
The work selection SHALL permit local shell history and SHALL NOT configure command history to be transmitted to an offsite service.

#### Scenario: Work shell session
- **WHEN** the work shell records a command in its local history
- **THEN** the shared work selection does not automatically transmit that history to an offsite server

### Requirement: Explicit shell actions
Shared shell helpers SHALL avoid silently approving project environment files or automatically replaying history without explicit user intent.

#### Scenario: Create project
- **WHEN** a helper creates a project containing an environment file
- **THEN** the file is not automatically approved for execution and the user is told how to review and approve it

#### Scenario: Replay history
- **WHEN** a user invokes history replay without explicitly requesting execution
- **THEN** the helper shows the commands without executing them

### Requirement: Portable host behavior
Shared shell settings SHALL avoid hard-coded rebuild paths and hosts belonging to another machine.

#### Scenario: Consumer imports shared shell
- **WHEN** a consumer uses shared shell settings without a configured rebuild target
- **THEN** no shared rebuild command targets an unrelated user's machine or path

### Requirement: Work adoption preserves consumer settings
The work adoption guidance SHALL preserve consumer-owned Git identity, secrets, Windows integration and local customizations, and SHALL require review and a host build before activation.

#### Scenario: Replace overlapping baseline
- **WHEN** a work consumer adopts shared Git, CLI or Zellij settings
- **THEN** the migration identifies overlapping definitions and preserves documented work-specific settings without importing a second competing baseline

## Purpose

Provide a reproducible Doom Emacs application that personal and work consumers can select without changing their development editor or sharing private data.

## ADDED Requirements

### Requirement: Reproducible installation
Doom and all enabled Emacs packages SHALL be built through Nix from locked sources. Startup and generation activation SHALL NOT require package downloads or a user-run package synchronisation command.

#### Scenario: Launch a built generation
- **WHEN** the built application starts with networking unavailable and fresh runtime directories
- **THEN** Doom loads its configured packages without downloading dependencies

#### Scenario: Roll back configuration
- **WHEN** a previous built generation is selected
- **THEN** its packaged Doom configuration and dependencies are restored without mutable package installation

### Requirement: Explicit feature selection
Consumers SHALL be able to select Doom independently of Neovim and desktop integration. An unselected feature SHALL install no Doom packages or services. Selecting Doom SHALL avoid competing vanilla Emacs executables.

#### Scenario: Select the feature
- **WHEN** a consumer imports the Doom feature alongside the existing Neovim feature
- **THEN** the configured Doom application is provided and Neovim settings remain unchanged

#### Scenario: Leave the feature unselected
- **WHEN** module discovery registers the feature without selecting it
- **THEN** no Doom packages or daemon enter the consumer environment

### Requirement: Minimal note editing environment
The application SHALL provide Evil modal editing, space-leader navigation, discoverable commands, completion, file and buffer navigation, Org editing and basic Git integration without requiring an IDE configuration.

#### Scenario: Edit an Org file
- **WHEN** the user opens an Org file in Doom
- **THEN** Org editing, Evil movement, leader commands and completion are available

### Requirement: Consumer compatibility
The exported feature SHALL use the consumer package set and support tested pinned stable and work-like unstable Home Manager configurations without personal credentials, hardware or unrelated desktop services.

#### Scenario: Build consumer fixtures
- **WHEN** both pinned consumer fixtures are evaluated and built
- **THEN** each provides Doom without fetching personal secrets or enabling Kitsune-specific services

### Requirement: Documented maintenance
Documentation SHALL explain selection, rebuilds, package and module changes, input updates, rollback and validation limits without requiring activation during automated checks.

#### Scenario: Maintain the application
- **WHEN** a maintainer follows the documented package-change workflow
- **THEN** they can build the resulting application declaratively before switching the active environment

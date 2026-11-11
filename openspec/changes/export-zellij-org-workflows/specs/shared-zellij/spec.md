# Spec Delta

## Purpose

Provides a portable Home Manager Zellij configuration that consumers can import as a complete, declarative replacement for their prior user configuration.

## ADDED Requirements

### Requirement: Reusable Zellij configuration
The flake MUST expose a Home Manager module that configures Zellij without requiring workstation-only options.

#### Scenario: Import in a consumer Home Manager profile
- **WHEN** a consumer imports the shared Zellij module
- **THEN** the generated configuration and layouts build without defining Kitsune-specific `home-config` options
- **AND** the shared module is the single owner of the consumer's Zellij configuration file

### Requirement: Org workflows from the Ctrl-b prefix
The shared Zellij configuration MUST preserve the Ctrl-b prefix and expose capture, agenda, and notes actions as floating panes.

#### Scenario: Launch Org capture
- **WHEN** the user presses Ctrl-b followed by e
- **THEN** Zellij launches `org-capture` in a floating pane that closes when the command exits

#### Scenario: Launch the agenda or notes
- **WHEN** the user presses Ctrl-b followed by a or r
- **THEN** Zellij launches `org-agenda` or `org-notes` respectively in a floating pane that closes when the command exits

### Requirement: Match Catppuccin Mocha
The shared Zellij configuration MUST select the Catppuccin Mocha palette.

#### Scenario: Start Zellij with the shared configuration
- **WHEN** Zellij loads the consumer's generated configuration
- **THEN** the selected theme is Catppuccin Mocha

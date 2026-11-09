## Purpose

Provide a welcoming, discoverable entry point to the user's knowledge workflows when opening Doom Emacs.

## ADDED Requirements

### Requirement: Knowledge-focused dashboard
The application SHALL provide Doom's startup dashboard with clearly labelled actions for capture, agenda, knowledge search and today's journal, as well as a recognizable graphical presentation and a readable terminal fallback.

#### Scenario: Open the initial screen
- **WHEN** the user opens a new graphical frame without selecting a file
- **THEN** the dashboard is available with its visual banner and knowledge workflow actions

#### Scenario: Open in a terminal
- **WHEN** the user opens Doom in a terminal
- **THEN** the dashboard remains readable and its actions are usable without graphical assets

### Requirement: Capture frames remain focused
External capture SHALL continue to open its dedicated capture interface without the dashboard replacing it or changing its existing cleanup behaviour.

#### Scenario: Capture from another application
- **WHEN** the user invokes the external capture helper
- **THEN** the capture interface appears, finalisation or cancellation closes only its frame, and the daemon remains running

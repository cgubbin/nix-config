# Terminal Org Clients

## Requirements

### Requirement: Terminal-only Org launchers
When graphical integration is disabled, the packaged Org commands MUST launch a text-terminal Emacs client and MUST NOT require X11 or Wayland environment variables.

#### Scenario: Open agenda in a terminal
- **WHEN** the user runs `org-agenda` from a terminal
- **THEN** the agenda is interactive in that terminal
- **AND** quitting the agenda returns control to the shell

#### Scenario: Capture from a terminal
- **WHEN** the user runs `org-capture` from a terminal
- **THEN** template selection and entry happen in the terminal client
- **AND** finalizing or cancelling capture closes that client and returns to the shell

#### Scenario: Open Org-roam notes in a terminal
- **WHEN** the user runs `org-notes` from a terminal
- **THEN** node selection and note browsing happen in the terminal client
- **AND** the user can close the client and return to the shell

### Requirement: Graphical host compatibility
When graphical integration is enabled, existing graphical Org frames and desktop launch bindings MUST remain available.

#### Scenario: Launch from the graphical workstation
- **WHEN** a host enables graphical integration and invokes an Org launcher
- **THEN** the launcher uses the graphical client workflow

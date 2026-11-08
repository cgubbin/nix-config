## Purpose

Ensure Kitsune's graphical session has predictable notification delivery and consistent locking and display resume behaviour.

## ADDED Requirements

### Requirement: Notifications have one lifecycle owner
Kitsune SHALL use SwayNC as its sole notification daemon, started once through the active graphical session lifecycle and stopped with that session.

#### Scenario: Start and end a desktop session
- **WHEN** a Hyprland session starts and subsequently ends
- **THEN** one SwayNC instance serves notifications during the session, no Mako instance competes for the notification bus name, and SwayNC stops with the session

### Requirement: Lock and resume commands are functional
Idle locking, pre-suspend locking, and visible lock actions SHALL use Hyprlock with the required authentication integration. Resume SHALL issue a valid display wake command. Existing timeout values SHALL remain unchanged unless separately selected by the user.

#### Scenario: Suspend and resume
- **WHEN** the session suspends and resumes
- **THEN** the lock action is requested before sleep and the display wake command includes its required arguments

#### Scenario: Invoke a visible lock action
- **WHEN** a configured desktop lock control is invoked
- **THEN** it invokes the same supported Hyprlock integration as idle locking

### Requirement: Idle actions are accurately described
The configuration SHALL distinguish display power-off from brightness dimming so that its option names and documentation describe the action performed.

#### Scenario: Inspect the display timeout setting
- **WHEN** a user reads the timeout controlling DPMS power-off
- **THEN** it is described as display power-off rather than brightness dimming

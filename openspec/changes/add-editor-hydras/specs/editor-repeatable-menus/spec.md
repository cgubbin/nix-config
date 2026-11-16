# Spec Delta

## Purpose

Make repeated debugging, hunk review and window actions single keystrokes inside a visible mode.

## ADDED Requirements

### Requirement: Repeatable action menus
The editor SHALL provide modal menus for debugging, Git hunk review and window resizing that repeat actions with single keys, display their available keys while active, and exit explicitly.

#### Scenario: Step through a debug session
- **WHEN** the user opens the debugging menu during a debug session
- **THEN** repeated single keys step over, into and out of code, continue, toggle breakpoints and show hover information until the user exits

#### Scenario: Review hunks
- **WHEN** the user opens the hunk review menu in a modified file
- **THEN** single keys move between hunks and stage, reset, preview or blame the current hunk until the user exits

#### Scenario: Exit a menu
- **WHEN** the user presses `q` or `<esc>` in any menu
- **THEN** the menu closes and normal mappings apply

### Requirement: Existing mappings preserved
Adding the menus SHALL NOT remove or change existing direct mappings for the same actions.

#### Scenario: Direct mapping still works
- **WHEN** the user invokes an existing direct mapping such as step over
- **THEN** it behaves as before the menus were added

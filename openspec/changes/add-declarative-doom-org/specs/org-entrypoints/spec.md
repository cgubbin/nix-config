## Purpose

Let users enter Org workflows from their existing development context using a reliable daemon and focused graphical frames.

## ADDED Requirements

### Requirement: Single managed daemon
When daemon support is enabled, one systemd user service SHALL own the Emacs daemon used by launch commands. Closing frames SHALL preserve the daemon. Restarting it SHALL be independent of a system rebuild.

#### Scenario: Concurrent launch
- **WHEN** two launch commands run while the daemon is stopped
- **THEN** both use the same managed daemon without creating competing instances

#### Scenario: Close and restart
- **WHEN** the user closes all frames and subsequently restarts the user service
- **THEN** frame closure does not stop the daemon and the service restart starts the configured application

### Requirement: Consistent launch commands
With daemon support enabled, `org-capture`, `org-agenda` and `org-notes` SHALL start the managed daemon if necessary and open their respective workflows. Ordinary client frame creation and opening a specified Org file SHALL also work with the running daemon.

#### Scenario: Launch from a development terminal
- **WHEN** the user invokes a launch command while Neovim is open
- **THEN** the requested Org workflow opens without changing Neovim buffers or working directory

### Requirement: Transient capture frame
External capture SHALL open a dedicated small frame with template selection or an explicit template key. Successful finalisation or cancellation SHALL close only that capture frame and leave ordinary frames and the daemon running.

#### Scenario: Finalise capture
- **WHEN** the user saves an external capture using the normal Org capture command
- **THEN** the entry is persisted and its dedicated frame closes

#### Scenario: Abort capture
- **WHEN** the user aborts an external capture while another Emacs frame exists
- **THEN** the capture frame closes without closing the ordinary frame or saving an unwanted entry

### Requirement: Session-aware graphical integration
Kitsune integration SHALL use its graphical session lifecycle. The WSL consumer path SHALL support on-demand launch using the current WSLg environment without requiring persistent graphics before WSL starts or manual environment repair on each restart.

#### Scenario: Launch after a WSL restart
- **WHEN** WSLg is available and a user launches a command from the new WSL session
- **THEN** it opens a graphical frame using that session's display environment

#### Scenario: Graphics are unavailable
- **WHEN** a graphical workflow is requested without a usable display environment
- **THEN** the command reports an actionable failure and does not launch competing fallback daemons

### Requirement: Discoverable host entrypoints
Kitsune SHALL provide capture and agenda shortcuts without conflicting with existing bindings. Documentation SHALL describe Windows shortcut invocation without claiming Nix manages Windows global shortcuts.

#### Scenario: Use a desktop shortcut
- **WHEN** the user invokes the documented Kitsune capture shortcut
- **THEN** it launches the same workflow as `org-capture`

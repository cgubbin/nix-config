# Spec Delta

## MODIFIED Requirements

### Requirement: Python tools use a coherent environment
Python language-server, lint, formatting, test, debug and notebook-kernel integrations SHALL expose their environment and use the selected project environment where supported, with limitations reported rather than hidden.

#### Scenario: Change project environment
- **WHEN** the user changes a project's Python environment
- **THEN** subsequent tools use the updated selection and existing language servers can be restarted to apply it

#### Scenario: Lint tools use a separate dependency group
- **WHEN** Ruff is available in a separate existing lint environment
- **THEN** the user can select that environment for live Ruff diagnostics and formatting independently of the environment used for direct tests and debugging

#### Scenario: Notebook kernel follows the selection
- **WHEN** the user changes the project's Python environment while a notebook is open
- **THEN** the next kernel started for that notebook uses the updated selection, and the running kernel's identity remains visible until it is restarted

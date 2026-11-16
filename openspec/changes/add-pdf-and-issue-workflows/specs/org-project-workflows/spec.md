# Spec Delta

## ADDED Requirements

### Requirement: External issue and review references
Org project tasks and engineering notes SHALL retain navigable Linear issue and GitHub issue or pull request references without becoming a competing copy of their shared state.

#### Scenario: Link a project task to Linear
- **WHEN** a user records a Linear issue identifier or URL on an Org task
- **THEN** the task retains the reference and the user can open the corresponding Linear issue from Emacs

#### Scenario: Link an engineering note to GitHub
- **WHEN** a user records a GitHub issue or pull request URL on an engineering note
- **THEN** the note retains a navigable link to that GitHub record

#### Scenario: Browse repository issues and pull requests
- **WHEN** a user opens a supported GitHub repository in Emacs with Forge authentication configured
- **THEN** the user can browse that repository's issues and pull requests from the Git workflow

#### Scenario: Shared status remains authoritative
- **WHEN** an Org task links to a Linear issue or GitHub record
- **THEN** Org does not automatically import, overwrite, or synchronize that service's shared status

#### Scenario: Keep credentials outside the Nix store
- **WHEN** an authenticated GitHub workflow requires a credential
- **THEN** Emacs reads it from the user's existing credential source and no secret is placed in Nix-managed configuration or the Nix store

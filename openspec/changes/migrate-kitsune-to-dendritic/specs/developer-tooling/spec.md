## Purpose

Provide a working Git environment whose generated settings and installed tools agree with the user's declared configuration.

## ADDED Requirements

### Requirement: Git settings are effective
Generated Git configuration SHALL expose the intended aliases, pull rebase, automatic stash, main default branch, and Delta pager settings using valid Git sections, without encoding Home Manager configuration containers as Git sections.

#### Scenario: Query generated Git configuration
- **WHEN** the generated configuration is queried with Git
- **THEN** alias.s, alias.cleanup, pull.rebase, rebase.autoStash, init.defaultBranch, and core.pager resolve to their intended values without extraConfig or aliases container sections

### Requirement: Configured tools are available
Kitsune SHALL install Delta when Git uses it as a pager, and SHALL provide the SOPS command for maintaining its existing secret files.

#### Scenario: Use configured tooling
- **WHEN** the user's generated environment is built
- **THEN** delta and sops executables are available and Git's configured pager resolves to Delta

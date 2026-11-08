## Purpose

Define the supported machine configuration and preserve Kitsune's operational settings as reusable features are composed.

## ADDED Requirements

### Requirement: Kitsune is the sole supported host
The flake SHALL expose Kitsune as its only machine configuration and SHALL NOT expose MacBook or work/WSL configurations or retain direct dependencies used exclusively by those retired targets.

#### Scenario: Inspect supported outputs
- **WHEN** the flake's machine outputs are evaluated
- **THEN** nixosConfigurations contains only kitsune and no Darwin machine configuration is available

#### Scenario: Retired dependencies are pruned
- **WHEN** the retained input graph is inspected
- **THEN** direct WSL, nix-darwin, Homebrew and AeroSpace inputs are absent and lock entries exist only if reachable from retained inputs

### Requirement: Feature selection is explicit
Making a feature available SHALL NOT implicitly enable its services or packages; Kitsune's composition SHALL select its intended features.

#### Scenario: An unselected feature is discovered
- **WHEN** a feature is registered but not selected by Kitsune or its selected dependencies
- **THEN** its packages and services do not enter the resulting machine configuration

### Requirement: Operational state is preserved
The migration SHALL preserve Kitsune's state versions, filesystems, boot and GPU configuration, account identity, secret provisioning, and Syncthing identity and folder settings except for explicitly documented fixes. User data and existing uncommitted work SHALL NOT be discarded.

#### Scenario: Compare migration results
- **WHEN** the migrated configuration is compared with the pre-migration working-tree baseline
- **THEN** critical settings match and every intentional package, service, or setting difference has a recorded reason

### Requirement: Maintenance validates the supported host
The repository SHALL provide checks for Kitsune evaluation and generated configuration as well as source linting, and instructions for building and rolling back without requiring immediate activation.

#### Scenario: Validate before activation
- **WHEN** the documented validation commands are run with required inputs accessible
- **THEN** Kitsune and its Home Manager configuration evaluate, generated-configuration checks execute, and a system build can be requested without switching the live system

### Requirement: Shared features have a consumer-facing interface
The flake SHALL export individually selectable Home Manager features for Git behaviour, shells, CLI tools, and the editor baseline. Consumers SHALL retain control of identity, credentials, machine settings, and optional integrations. Kitsune SHALL consume the same definitions for its selected shared behaviours.

#### Scenario: Work-like consumer selects shared features
- **WHEN** a consumer imports shared features with its own Git identity and editor extensions
- **THEN** the shared behaviour is available without personal identity, Kitsune hardware, desktop services, cloud accounts, AI tools, or secret provisioning being enabled implicitly

### Requirement: Shared features support tested consumer inputs
Shared features SHALL be checked against Kitsune's stable input set and an explicitly pinned work-like unstable input set. They SHALL use consumer package sets and documented companion modules, without requiring personal secrets or company-private inputs to evaluate the compatibility fixtures.

#### Scenario: Evaluate compatibility fixtures
- **WHEN** the stable and unstable consumer fixtures are evaluated and their generated configurations checked
- **THEN** shared features compose with consumer identity and extensions in both fixtures and do not require access to personal secrets or company services

### Requirement: Consumer updates are explicit
The adoption guide SHALL describe a lockfile-pinned source, deliberate updates and rollback, supported export names and dependencies, and replacement of overlapping local or company-starter features. Updating this repository alone SHALL NOT update a consumer's locked configuration.

#### Scenario: Adopt a shared feature
- **WHEN** the work maintainer follows the guide for one feature
- **THEN** they can identify the overlapping definition to replace, retain work-specific overrides, evaluate the result, and roll back the input revision independently

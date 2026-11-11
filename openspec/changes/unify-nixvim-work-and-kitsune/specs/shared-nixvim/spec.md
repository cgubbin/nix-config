## Purpose

Provide a common, configurable Nixvim baseline for personal and work environments while preserving consumer-specific integrations.

## ADDED Requirements

### Requirement: Shared editor preserves the newer work baseline
The shared editor SHALL use the work configuration as the precedence baseline for common editor behaviour, keymaps, plugins and assets, except for documented defect corrections and explicitly consumer-specific settings.

#### Scenario: Shared editor replaces the older baseline
- **WHEN** a supported consumer builds the shared editor
- **THEN** work's intended completion, navigation, snippets, testing, debugging and notebook behaviours are retained or their intentional changes documented

### Requirement: Consumers own private and machine-specific settings
The shared editor SHALL use the consumer's package set and Nixvim companion module, and SHALL permit personal vaults, terminal integration, work-specific plugins, paths and private inputs to be supplied as separate extensions.

#### Scenario: Consumer omits work-specific dependencies
- **WHEN** Kitsune or a minimal synthetic consumer imports the shared editor without work-only inputs
- **THEN** it evaluates and starts without requiring company services, workbench, private plugin sources or a work vault

#### Scenario: Consumer adds an extension
- **WHEN** a consumer supplies its own vault, plugin or terminal settings
- **THEN** those settings compose without importing a second copy of the shared editor or forcing another consumer's identity or paths

### Requirement: Both supported dependency sets are verified
Shared editor checks SHALL evaluate and build against the existing stable and work-pinned unstable Home Manager, nixpkgs and Nixvim combinations using consumer packages.

#### Scenario: Run shared compatibility checks
- **WHEN** checks run with the pinned inputs available
- **THEN** both editors build, start headlessly without startup errors, and expose the intended baseline and test extension

### Requirement: Work adoption is reviewable and non-duplicating
The repository SHALL provide a work-consumer integration patch and instructions that select the shared editor once, retain the matching companion module and work-specific extensions, and exclude the previous recursively discovered editor files.

#### Scenario: Test the consumer patch
- **WHEN** the patch is applied to an isolated copy of the recorded work-repository baseline
- **THEN** its generated configuration contains one editor baseline and preserves work-specific integrations without duplicate hooks or keymaps

#### Scenario: Follow the adoption procedure
- **WHEN** the maintainer adopts a published producer revision in the actual work repository
- **THEN** the instructions explain pinning, flake-file regeneration, evaluation, real-host validation and rollback without changing host identity or secrets

### Requirement: Nixvim audit records evidence and disposition
The repository SHALL document identified defects and capability gaps, including evidence, impact, verification and disposition, distinguishing fixed issues from optional or environment-dependent recommendations.

#### Scenario: Review an audit finding
- **WHEN** a maintainer reads the audit
- **THEN** they can identify whether the finding was verified, fixed, deferred or requires a project-provided dependency

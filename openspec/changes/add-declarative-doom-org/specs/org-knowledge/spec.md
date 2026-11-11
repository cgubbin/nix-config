## Purpose

Support personal task capture and linked technical knowledge while keeping note contents separate from declarative configuration and from other hosts.

## ADDED Requirements

### Requirement: Host-owned writable notes
Each consumer SHALL configure its own absolute Org root. Notes and attachments SHALL remain writable user data outside the Nix store. The feature SHALL NOT configure note synchronisation or overwrite existing notes during activation or launch.

#### Scenario: Use distinct roots
- **WHEN** personal and work consumers select different Org roots
- **THEN** captures and searches use their own root and no synchronisation between roots is introduced

#### Scenario: Rebuild with existing notes
- **WHEN** configuration is rebuilt after notes have been edited
- **THEN** existing note contents remain intact

### Requirement: Capture and agenda
The application SHALL provide inbox, TODO, scientific concept, engineering investigation and meeting capture templates with predetermined destinations. Inbox and task commitments SHALL appear in the agenda when actionable.

#### Scenario: Capture a task
- **WHEN** the user selects the TODO template and finalises an entry
- **THEN** it is saved under the configured root and appears in the agenda without manual path selection

### Requirement: Linked knowledge
Users SHALL be able to create and find Org-roam nodes, insert stable identifier links and view backlinks. The node database SHALL reside in writable host-local runtime storage outside managed configuration.

#### Scenario: Link two concepts
- **WHEN** a user creates two nodes and inserts a link from one to the other
- **THEN** the target can be found by its identifier and its backlinks show the source after database synchronisation

### Requirement: Daily journal
The application SHALL create and navigate dated daily notes under the configured root without requiring manual file selection.

#### Scenario: Open today's note twice
- **WHEN** the user invokes today's journal command twice on the same date
- **THEN** both invocations reach the same daily note and preserve existing content

### Requirement: Explicit code execution
Opening Org documents SHALL NOT automatically execute embedded code. Interactive Babel execution SHALL retain confirmation unless the user explicitly grants a narrower trust policy later.

#### Scenario: Open an untrusted document
- **WHEN** the user opens an Org file containing source blocks
- **THEN** no source block executes merely because the document was opened

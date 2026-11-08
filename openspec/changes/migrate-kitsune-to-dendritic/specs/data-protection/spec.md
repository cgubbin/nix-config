## Purpose

Protect synchronized media from missing-mount errors and make the limits of declarative backup coverage visible to the maintainer.

## ADDED Requirements

### Requirement: Media synchronization requires its source mount
Syncthing SHALL NOT scan or send the pi-media folder from the underlying root-filesystem directory when the expected filesystem is absent at /mnt/Media. Loss of the source mount SHALL stop synchronization safely without propagating deletions from that underlying directory.

#### Scenario: Media disk is unavailable at service start
- **WHEN** the configured media filesystem is not mounted
- **THEN** the media synchronization service does not start against /mnt/Media/pi and reports the missing prerequisite

#### Scenario: Media filesystem is unmounted
- **WHEN** the media mount is stopped during normal system operation
- **THEN** synchronization stops before it can scan the uncovered directory

#### Scenario: Media filesystem is available
- **WHEN** the expected filesystem is mounted and synchronization starts
- **THEN** the existing pi-media path, send-only mode, peer IDs, and identity are preserved

### Requirement: Backup coverage is explicit
The repository SHALL distinguish the installed Restic client from configured scheduled jobs, document that no local jobs are defined if that remains the case, and SHALL NOT invent a repository, credentials, retention policy, or claim verified external backups.

#### Scenario: No local backup job is configured
- **WHEN** the maintainer reads the backup configuration and audit documentation
- **THEN** Restic remains available as a client and the absence of local schedules and the unverified status of external coverage are explicit

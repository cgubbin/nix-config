# Tasks

## 1. Composable CLI and history

- [x] 1.1 Split common CLI and optional personal features into independently selectable exports; evaluate stable and work-like consumers to verify the common baseline excludes Atuin and history synchronization.
- [x] 1.2 Preserve Kitsune's explicitly selected CLI and Atuin behavior and compatibility of existing exports; compare generated options and package selection against the prior configuration and document any migration.
- [x] 1.3 Document the local-history boundary and inspect generated Fish/Nushell and service settings for offsite history sync; verify the work fixture has no Atuin integration or history sync service.

## 2. Shell helpers

- [x] 2.1 Remove or parameterize unrelated rebuild aliases; test generated Fish configuration for absence of the stale user, path and host.
- [x] 2.2 Make history replay preview by default and require an explicit execution option; verify with disposable harmless commands that preview never executes and explicit execution behaves as documented.
- [x] 2.3 Remove automatic `direnv allow` from project creation and provide a review/approval instruction; use disposable templates to verify the generated `.envrc` remains unapproved.

## 3. Candidate tools

- [x] 3.1 Evaluate nbdime and Difftastic with disposable notebook and code diffs and both consumer package sets; document usage and add selected tools without globally changing Git merge behavior.
- [ ] 3.2 Compare a local secret scanner with work's existing tooling and policy on the actual work machine; record the decision without copying findings or secrets, and test any selected tool using synthetic fixtures.

## 4. Work adoption

- [x] 4.1 Recheck the work repository revision and overlapping Git, CLI and Zellij modules, then produce a reviewed migration or patch preserving identity, ignores, Windows integrations, secrets and work overlays; verify it against a disposable copy.
- [ ] 4.2 Document exact work input pinning, baseline replacement, host build, interactive history and tool checks, and rollback; verify examples against the reviewed work revision and keep real-host results pending until tested there.
- [ ] 4.3 On the work laptop, review and apply the migration within the work repository's own instructions, build before activation and verify Git, Zellij, tools and local-only history; record sanitized outcomes.

## 5. Integrated validation

- [x] 5.1 Run relevant checks for stable and work-like consumers and a non-activating Kitsune build; report separately any work-host validation that remains outstanding.

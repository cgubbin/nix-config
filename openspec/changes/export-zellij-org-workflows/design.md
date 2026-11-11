# Design

## Context

The current Zellij configuration is defined by an internal Home Manager module under `modules/development` and includes a complete generated KDL config plus layouts. Public consumer modules are exposed separately through flake-parts. Zellij reads a single effective config, so layering a shared module over a Work-local generated config would leave ownership ambiguous. See `proposal.md` for the motivation and `specs/shared-zellij/spec.md` for required behavior.

## Goals / Non-Goals

**Goals:**

- Export the existing Zellij experience as a self-contained Home Manager module usable by external flake consumers.
- Preserve Kitsune's current opt-in gate while allowing Work to explicitly replace its local Zellij configuration.
- Keep the generated KDL and layouts versioned with the same flake revision as the Doom/Org commands they invoke.

**Non-Goals:**

- Merge arbitrary consumer KDL fragments or expose every keybinding and layout as a new option.
- Change Zellij's Ctrl-b interaction model or redesign existing layouts as part of the export.
- Modify Windows-level shortcuts; those remain a Work machine concern.

## Decisions

1. **Export one complete `shared-zellij` Home Manager module.** Define it alongside the existing public shared features and expose it under `flake.modules.homeManager.shared-zellij`. A single owner matches Zellij's generated-config model and avoids fragile KDL composition. Alternatives considered: exporting only Org bindings (insufficient for the requested replacement) or supporting fragments (conflicts and ordering are hard to reason about).

2. **Make the public module independent of Kitsune's `home-config` options.** It must be importable in consumer Home Manager evaluations without defining internal host options. Kitsune's internal `home-kit-features-dev-zellij` wrapper will import the shared module and retain the existing `devTools.enable` condition by controlling whether the shared module is imported/enabled at the internal composition boundary. The exported module itself must not inspect workstation-only settings.

3. **Treat Work migration as replacement, not layering.** Work removes its current local `programs.zellij` and generated `config.kdl`/layout declarations, then imports the public export. The shared module writes the authoritative config and layouts; its shell commands remain provided by the shared Doom export. This avoids duplicate Home Manager file declarations and makes future updates lockfile-driven.

4. **Do not add a flake input or standalone package manager.** Consumers already import the repository for other shared features, so Zellij configuration ships at the same pinned revision. This keeps the lock graph unchanged and lets normal Nix generations provide rollback.

5. **Validate through an external-consumer fixture and generated KDL.** Evaluate/build a minimal Home Manager consumer with only the shared export, verify it requires no Kitsune options, and assert the expected theme, Ctrl-b prefix, Org launch actions, and layouts appear in generated files. Parse the resulting KDL with the repository's available validator when practical. Also build Kitsune's existing profile to catch gate/composition regressions.

## Risks / Trade-offs

- [The Work profile may currently define the same Zellij files through more than one module] → Document the explicit removal of local declarations and test a consumer that imports the public module without duplicate targets.
- [The existing internal development gate may be lost during extraction] → Keep the gate in the internal wrapper and evaluate Kitsune both with the feature disabled and enabled where fixtures permit.
- [Org launcher bindings depend on commands from the Doom feature] → Document the paired export expectation and keep command names stable; Zellij itself remains usable if those commands are absent, but the Org actions will fail at invocation.
- [A public module that owns all settings offers less per-consumer customization] → Prefer the stable shared baseline for this request; add narrowly scoped options only when a demonstrated consumer need arises.

## Migration Plan

1. Extract the current module's config and layouts into the public `shared-zellij` module.
2. Change Kitsune's internal development module to import the export while preserving its current enable gate.
3. Add consumer evaluation/build checks and update shared-feature documentation with the module path and replacement instructions.
4. In the Work repository, remove its previous Zellij config declarations, import `inputs.personal-features.modules.homeManager.shared-zellij`, update the input lock to the desired revision, and rebuild.
5. Roll back by reverting the Work import/removal and restoring its prior local module, or by pinning the prior flake revision; no note data or mutable Zellij state is migrated.

## Open Questions

None. Consumer-specific theme or layout overrides can be considered later without changing the export architecture.

# Tasks

## 1. Public shared module

- [x] 1.1 Extract the complete Zellij configuration and layouts into `modules/shared/zellij.nix`, expose `shared-zellij`, and verify the module evaluates without Kitsune-only options.
- [x] 1.2 Refactor the internal development Zellij feature to consume the shared module while preserving the `devTools.enable` gate; verify Kitsune profile evaluation with Zellij enabled and disabled.

## 2. Consumer validation and documentation

- [x] 2.1 Add a minimal external-consumer Home Manager check for the shared module and assert Catppuccin Mocha, Ctrl-b Org actions, and generated layouts are present; run the check and available KDL validation.
- [x] 2.2 Document the public export path and Work replacement migration in `docs/shared-features.md`; verify the example import and removal steps match the evaluated module.

## 3. Integration

- [x] 3.1 Run formatting and relevant flake/Home Manager checks for both the Kitsune composition and standalone consumer, and confirm the shared module introduces no duplicate generated Zellij files.

## Workflow follow-up

- Update the Work repository to import `shared-zellij`, remove its previous local Zellij config declarations, lock the desired personal-features revision, and rebuild the Work host.
- Verify Ctrl-b followed by e, a, and r launches capture, agenda, and notes in the Work Zellij session.

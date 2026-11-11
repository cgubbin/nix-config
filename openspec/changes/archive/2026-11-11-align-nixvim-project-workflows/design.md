# Design

## Context

The work repositories are inaccessible here. The user states Just wraps Nox, which installs from lockfiles into isolated environments. Existing Overseer templates hard-code recipes and uv; direct Neotest and DAP use a separate resolver. Existing project environment isolation and consumer fixtures provide a baseline.

## Goals / Non-Goals

**Goals:** Discover project-owned tasks, let the user deliberately select environments, and make tool provenance and limitations visible. Verify representative public disposable fixtures under both pinned consumers.

**Non-Goals:** Infer arbitrary Nox session internals, mutate private work repositories, automatically install environments, or claim real-host verification.

## Decisions

- Discover Just recipes through its structured listing in the project directory, with bounded execution, error reporting, and no implicit recipe execution. Expose arguments as a prompt and run through direnv. Replace hard-coded recipe templates.
- Keep Just/Nox execution as a project task. Direct pytest and DAP remain separate and explicitly labeled: arbitrary Nox sessions can perform setup that cannot safely be reverse-engineered. A project-provided debug recipe can be run as a task.
- Maintain an in-memory per-project environment selection. Offer detected `.venv` and Pixi environments with an explicit selection; use executable paths and approved direnv exports. Do not invoke commands that synchronize or install environments during detection. Missing selected environments fail clearly rather than falling back silently.
- Support a separate project-selected existing tool environment for Ruff when lint dependencies live in a different group or Nox environment. Keep test/debug interpreter selection independent. The project Just/Nox lint recipe remains the authoritative check and environment creation is explicit.
- Apply selected Python environment consistently to direct test/debug and supported language-server, linter and formatter subprocesses. Restart existing LSP clients on explicit refresh or instruct the user where restart is necessary. Avoid global `vim.env` mutation.
- Prefer project-provided tools in the selected environment, preserve existing configured behavior for non-Python projects, and avoid duplicate Ruff diagnostics.

## Risks / Trade-offs

- [Project recipe listing may evaluate project configuration] → Only discover on explicit user action, in the approved environment; document that project configuration is trusted code.
- [Nox sessions vary and may prepare services or runtime state] → Run the project-owned recipe; do not fabricate equivalence with direct DAP or pytest.
- [Private projects are unavailable] → Tests use disposable representative fixtures and real-work validation is recorded as pending.

## Migration Plan

Replace fixed Overseer recipes with discovery; preserve a direct test/debug path with clear environment information. Roll back by restoring the prior editor commit. Validate both pinned consumers and Kitsune without activation before applying on either host.

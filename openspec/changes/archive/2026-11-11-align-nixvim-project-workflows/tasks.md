# Tasks

## 1. Project tasks

- [x] 1.1 Replace fixed Overseer Just recipes with explicit project-scoped structured discovery and argument handling; verify distinct projects, missing Just, invalid files, arguments and no implicit task execution in headless fixtures.
- [x] 1.2 Exercise a disposable Just-to-Nox-style isolated-session workflow and document that direct pytest and DAP are separate; verify recipe exit and output are preserved.

## 2. Python environment selection

- [x] 2.1 Add visible per-project uv `.venv` and named Pixi selection without implicit installation or silent fallback; verify absent, changed, named and isolated A/B/A project environments.
- [x] 2.2 Apply selected environments to direct testing and debugging, identify the selected interpreter, and verify real disposable pytest and debugpy launches along with errors and refresh behavior.
- [x] 2.3 Align Python LSP, lint and formatting with selected project tools where supported, avoid duplicate Ruff diagnostics, and verify project isolation and visible missing-tool behavior with fixtures.

## 3. Integration

- [x] 3.1 Document commands, trust boundaries, project prerequisites and the limits of Nox equivalence; verify examples and real-work-host follow-up are explicit.
- [x] 3.2 Run lint, both pinned consumer headless checks and a non-activating Kitsune build; record real uv/Pixi/Nox project validation as pending when unavailable.

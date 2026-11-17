# Spec Delta

## Purpose

Makes pixi available to Emacs and the user's shells from the home profile, so that Org Babel
blocks can run in a pixi workspace (for example a notes repository's computational lab) without
first entering a project dev shell.

## ADDED Requirements

### Requirement: pixi on the profile PATH
The home profile SHALL provide a `pixi` command on the PATH that Emacs and login shells use.

#### Scenario: From the Emacs daemon
- **WHEN** Emacs, started by the user's session and not from a project shell, evaluates `(executable-find "pixi")`
- **THEN** it returns a path

### Requirement: Conda-forge binaries run
Programs that `pixi` installs from conda-forge SHALL run on this NixOS host without changing the
pixi workspace.

#### Scenario: Python from a pixi workspace
- **WHEN** a pixi workspace with a conda-forge `python` has been installed and the user runs `pixi run --as-is python -c "print(1)"` in it
- **THEN** it prints `1`

### Requirement: Babel block in a pixi workspace
A Python Babel block with `:python "pixi run --as-is python"` and `:dir` set to an installed pixi
workspace SHALL run in that workspace's environment after the user confirms it.

#### Scenario: Confirmed block
- **WHEN** the user confirms such a block that imports a package present only in the workspace
- **THEN** the block's result is shown and no error is raised

#### Scenario: Workspace not installed
- **WHEN** the workspace has not been installed and the block is confirmed
- **THEN** the block fails with pixi's error, and nothing is installed or downloaded

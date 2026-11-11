# Design

The existing `knowledge.enableGraphicalIntegration` host option selects the launcher mode. When false, the shell wrapper starts the systemd-owned daemon on demand without importing display variables, then invokes `emacsclient --tty` with an Emacs Lisp entrypoint. The client remains attached while the user interacts with the selected Org workflow. The systemd service clears inherited display variables for terminal-only consumers so stale WSLg values cannot break daemon startup.

Agenda `q` closes the dedicated terminal client frame. Capture exits through Org's after-finalize hook on both save and cancel. The Org-roam client stays interactive while browsing and offers `q` to close the client. Zellij consumers can open these clients in floating panes that close when the client exits. Graphical hosts continue using the existing frame implementation and Hyprland bindings.

This keeps all note content and package management unchanged and avoids WSL-specific behaviour in Doom Lisp.

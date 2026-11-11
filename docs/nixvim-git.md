# Git and code navigation in Nixvim

The configured leader is `\`. In the mappings below, `<leader>` means that
key. The shared editor uses its consumer's pinned plugin packages.

- `<leader>gg` opens LazyGit. Select its local or remote branches panel and
  press Space on a branch to check it out. LazyGit also shows changes, staging,
  commits, stashes and worktrees; use its `?` help for the installed version.
- `<leader>gP` opens Octo's GitHub pull request picker. Select a PR to view it,
  or use the picker's `<C-o>` action to check it out. `:Octo review` opens the
  PR review workflow. Octo uses the authenticated GitHub CLI; its network and
  authentication behavior belongs to the current repository and account.
- `<leader>gd` opens Diffview for changes and merge conflicts; `<leader>gD`
  closes it. `<leader>gH` opens history for the current file. `g?` inside a
  Diffview panel shows the plugin's mappings. Telescope's commit and branch
  pickers also offer `<C-d>` to open a comparison.
- `]c` and `[c` move between Git hunks. `<leader>hs` stages a hunk or visual
  selection; `<leader>hr` resets one. `<leader>hP` previews a hunk, and
  `<leader>hb` shows blame. Reset actions discard the selected working-tree
  changes; inspect the preview first if needed.
- `<leader>cO` toggles Aerial's code outline. Navic supplies the current
  language-server symbol path in the winbar when a supporting server attaches.
  Trouble's existing `<leader>cs` remains available as an alternative symbols
  view.

The automated checks use a disposable local Git repository, including a merge
conflict. GitHub authentication, real PR checkout/review and interactive
terminal behavior still need verification in the user's session.

Zellij layouts for your dev workflow (high ROI)
Neovim + fzf integration (Telescope vs CLI)
Nix devshell + Zellij integration


1. Neovim integration
Make your editor and shell feel like one system:

file search and live grep inside Neovim
git workflows in-editor vs CLI
make sure Nix/direnv/devshell behavior is smooth from Neovim
decide where Telescope or fzf-lua should replace shell helpers

2. Git workflow cleanup
You already have helpers, but this is where a lot of daily friction hides:

commit/rebase/stash flow
diff/pager setup
deciding what belongs in shell helpers vs lazygit
better defaults for branch/log/status browsing

3. Nix/devshell polish
Your templates are good; the next step is consistency:

standardize all templates
unify .envrc, justfile, checks, shellHook style
make project creation commands perfectly consistent

4. Monitoring / ops tools
Tighten the “operate the machine” side:

bottom, procs, duf, journalctl workflows
service inspection shortcuts
systemd user/system helpers

5. Startup/performance maintenance
Now that you’ve added a lot, it’s worth checking:

Fish startup time
unnecessary shell init work
whether prompt/git info stays fast in big repos

My recommendation is Neovim integration next. That’s where your shell and project tooling will start compounding instead of feeling adjacent.

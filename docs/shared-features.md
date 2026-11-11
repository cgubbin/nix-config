# Shared features

This repository exports `modules.homeManager.shared-git`, `shared-shells`,
`shared-cli`, `shared-editor`, and `shared-doom-emacs`. Kitsune uses the same definitions. Discovery
alone does not enable them. All use consumer `pkgs`; identities, credentials,
state versions and machine settings belong to the consumer.

| Export | Behaviour | Consumer ownership / prerequisites |
| --- | --- | --- |
| shared-git | aliases, pull/rebase, main default, Delta | Git name/email/github identity; no forced identity or SSH agent |
| shared-shells | fish, Nushell, direnv and integrations | secret sourcing, Windows environment, project-template availability |
| shared-cli | CLI packages and Atuin/Bat/FZF/Yazi/etc. | history sync choices, shell binding overrides; no cloud/AI service selection |
| shared-editor | Nixvim baseline, plugins, snippets | matching Nixvim Home Manager companion module; work-only extensions and personal vault configuration |
| shared-doom-emacs | Declarative Doom, Org capture/agenda/roam, optional managed daemon | Linux consumer; independent writable Org root; optional graphical session integration; see [Doom/Org guide](emacs-org.md) |

The shared editor accepts `sharedEditor.configDirectory` (a consumer-owned
directory for the editor configuration shortcut), `sharedEditor.clipboardProvider`
(`null`, `"wl-copy"`, `"xclip"`, or `"xsel"`),
`sharedEditor.imageBackend` (`"kitty"`, `"ueberzug"`, or `"sixel"`), and
`sharedEditor.quartoSyncPackage` (an optional consumer-provided Vim plugin
package). A missing or nonexistent configuration directory produces a warning
when the shortcut is used. Quarto sync remains disabled unless its package is
supplied. Clipboard and image behavior still need a real terminal check.

Stable fixture uses this repository's locked stable nixpkgs/Home Manager/Nixvim.
Work-like fixture uses nixpkgs `319e4cebef10cbb636c6ea392137b52ad105336a`,
Home Manager `640725978b99076e18e069f6e7d2959124584f8f`, and Nixvim
`8485794923eb406ce3728af320392226608f724b`, taken from the inspected work lockfile.
Exact hashes and companion dependencies are recorded in flake.lock. Support is
for tested pins; run compatibility checks when updating either repository.

Minimal synthetic consumers are available as `homeConfigurations.shared-stable`
and `homeConfigurations.shared-unstable`. They import all four exports with a
synthetic identity and an additional editor global. They do not instantiate the
Kitsune host or configure private secrets, company inputs, or local workbench.
The producer's flake metadata still lists its private host input; public modules
must not force it. This is not a promise that the input graph contains no private
metadata.

## Staged work adoption (follow-up, not performed here)

### Work editor patch

The reviewable patch is
`openspec/changes/unify-nixvim-work-and-kitsune/work-consumer.patch`. It was
generated from work commit `eead8734c13fdaa31be509466ddb3ee6fd4142bf` and
also passed `git apply --check` against the clean work commit
`287e505302c2ae758583c44e97bb739a88a32c25`. The latter adds a separate
`personal-features` input for Doom. That input's revision is not an ancestor of
the current editor producer checkout, so the patch adds `shared-nixvim` instead
of changing the Doom input. A later combined producer revision could remove the
extra input after its Doom and editor exports are verified together.

The patch keeps work's matching `inputs.nixvim.homeModules.nixvim`, places the
old tree under `_nixvim` so import-tree ignores every file in it, and moves only
the work Obsidian and Claude modules back into discovered paths. It supplies
the private Quarto source as a package, along with xsel, Kitty and the work
config path. The checked-in producer URL contains
`REPLACE_WITH_REVIEWED_REVISION` intentionally: replace it with the published,
reviewed immutable revision before evaluating the real work configuration.
The isolated test used fake workbench, kuiui, secrets and Quarto inputs and a
disposable vault. It is not a real work-host build.

In a separately authorized work-repository workflow:

1. Check the work repository's instructions and `git status --short`; save the
   previous source and lockfile revisions. Recheck its HEAD and review the patch
   if anything has changed since the recorded work commit. Make the reviewed
   patch available on the work machine, then run `git apply --check <patch-path>`
   from the work repository before applying it.
2. Apply the reviewed patch. In `modules/users/kit.nix`, replace the placeholder
   in the `shared-nixvim` URL with the published producer revision. Regenerate
   the generated flake using a matching override so the placeholder is never
   resolved, for example:

   ```sh
   producer_rev=REPLACE_WITH_PUBLISHED_COMMIT
   nix run --no-write-lock-file \
     --override-input shared-nixvim "github:cgubbin/nix-config/$producer_rev" \
     .#write-flake
   ```

3. Review the generated `flake.nix` diff, then update the `shared-nixvim` lock
   entry and review the entire lock diff. At the inspected newer work commit,
   the already-declared `personal-features` Doom input did not yet have a lock
   entry; locking may also add that missing entry. Verify it resolves to the
   existing intended Doom revision and that unrelated pins stay unchanged.
   Never commit a local `path:` or `git+file:` test override to the lockfile.
4. With the real work inputs available, run
   `nix build --no-link .#nixosConfigurations.work.config.system.build.toplevel`
   and review its result before activation. Exercise Python tests and debugging,
   Rust tasks, notebook creation and save, Quarto preview, clipboard, terminal
   images, the work vault and Claude on the actual host. Project environments
   need `direnv` approval, pytest for Python tests, and Cargo plus cargo-nextest
   for Rust tests. Use `:ProjectEnvRefresh` after changing an environment and
   restart already-running language servers to pick it up.
5. To roll back, restore both the prior work source and lockfile revisions and
   rebuild the prior configuration. Keep those revisions until the real-host
   checks have passed.

The shared notebook conversion intentionally uses temporary files: a sibling
Markdown file is not treated as a paired notebook and is not overwritten.

In the shared editor, `<leader>Or` discovers the current project's Just
recipes and runs the selected recipe as an Overseer task. Discovery is an
explicit action and loads the approved direnv environment; project Just
configuration must be trusted. Project recipes may invoke Nox from their
own development dependencies. Direct Neotest and DAP actions use a Python
interpreter separately and do not reproduce a Nox session's setup.

Use `:ProjectPythonSelect` to select an existing `.venv`, named Pixi, or Nox
environment for direct test and debug actions. `:ProjectRuffSelect` separately
chooses an existing environment containing Ruff, for example a Nox lint group;
`:ProjectPythonInfo` shows the current selections. These selections are per
project and last for the editor session. Restart running language servers
after changing them. The editor does not install dependency groups: prepare them
using the project's own commands. If a selected interpreter or Ruff disappears,
the corresponding operation reports an error rather than choosing another tool.
Pixi activation is offline, frozen, and uses `--no-install`; selection is limited
to environments already present on disk. Real work-project behavior, including
the actual lockfiles and session setup, still requires validation on the work PC.
Pyright uses a project-provided language server when present and otherwise the
configured Nix-provided server, with the selected Python path passed to it.

For other shared features, the work flake is generated by flake-file. Declare
inputs in a module rather than editing generated `flake.nix`; reuse an existing
input if it already supplies the desired export. The following is a generic
example for a consumer that does not already declare `personal-features`:

```nix
{ inputs, ... }: {
  flake-file.inputs.personal-features.url = "github:cgubbin/nix-config";
  flake.modules.homeManager.kit = {
    imports = [ inputs.personal-features.modules.homeManager.shared-git ];
    programs.git.settings.user = {
      name = "kit";
      email = "YOUR_WORK_EMAIL";
    };
  };
}
```

Start with Git, then CLI; shells/editor are larger migrations. For each export:

1. Remove the corresponding company-starter import and overlapping local baseline
   definitions. For Git, replace the starter Git import and keep only work identity,
   ignores and intentional settings from local git.nix. For CLI, compare starter
   cli-tools plus local tools and individual tool modules; keep work-only packages
   and demonstrated unstable workarounds in a separate extension. Never import two
   competing baselines and hide conflicts with blanket mkForce.
2. For shells, replace local fish/Nushell/direnv baseline while preserving env.nix
   secret sourcing and Windows browser wrappers. The project helper expects
   templates in `~/Templates/nix-templates`; provision them or override the helper.
3. For editor, retain the work consumer's matching Nixvim companion module, replace
   common local baseline imports, and reapply work-only plugins, Python/workbench
   integrations, Quarto sync and vault choices explicitly. Do not auto-import the
   complete local editor tree alongside the shared editor.
4. Regenerate using the work repository's `nix run .#write-flake` workflow, then
   update/lock the new input and evaluate/build its actual work host. Check its
   own AGENTS/instructions first. Compare generated settings and package versions.
5. For pre-publication tests use `--override-input personal-features path:/home/kit/nix-config`
   with `--no-write-lock-file` after generation; do not commit a local-path lock.

Producer updates alone do not change the consumer lock. Deliberately run
`nix flake update personal-features` in the consumer, review its lock diff and
settings, and build before activation. Preserve the previous lockfile commit for
rollback; revert that input update and rebuild to restore previous definitions.
Treat removal/renaming of exports or mandatory companion changes as breaking
changes requiring an explicit consumer migration. The work host and company
starter remain independently owned; exports do not resolve divergence until the
work repository actually adopts them.

The unstable fixture retains the work consumer's local see-cat C17 and semgrep
PyJWT dependency workarounds via its own package overlay. The first full consumer
build reproduced the see-cat/glibc 2.44 bsearch failure without that overlay.
These are consumer input-specific adjustments, not changes to the shared feature
definitions or Kitsune's package set.

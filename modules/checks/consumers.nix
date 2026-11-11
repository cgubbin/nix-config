{ inputs, config, ... }:
let
  hm = config.flake.modules.homeManager;
  make =
    manager: packages: editor: workarounds:
    manager.lib.homeManagerConfiguration {
      pkgs = import packages {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = inputs.nixpkgs.lib.optional workarounds (
          _final: prev: {
            # Consumer-local workarounds already present in the inspected work repo.
            see-cat = prev.see-cat.overrideAttrs (old: {
              env = (old.env or { }) // {
                CFLAGS = "-std=gnu17";
              };
            });
            semgrep = prev.semgrep.overridePythonAttrs (old: {
              pythonRelaxDeps = (old.pythonRelaxDeps or [ ]) ++ [ "pyjwt" ];
            });
          }
        );
      };
      modules = [
        editor.homeModules.nixvim
        hm.shared-git
        hm.shared-shells
        hm.shared-cli
        hm.shared-editor
        ({ pkgs, ... }: {
          home = {
            username = "consumer";
            homeDirectory = "/home/consumer";
            stateVersion = "26.05";
          };
          programs.git.settings.user = {
            name = "Consumer";
            email = "consumer@example.invalid";
          };
          programs.nixvim.globals.consumer_extension = true;
          programs.nixvim.plugins.obsidian = {
            enable = true;
            settings.workspaces = [
              {
                name = if workarounds then "work-fixture" else "personal-fixture";
                path = if workarounds then "/nix/store" else "/tmp";
              }
            ];
          };
          sharedEditor.configDirectory = if workarounds then "/nix/store" else "/tmp";
          sharedEditor.clipboardProvider = if workarounds then "xsel" else null;
          sharedEditor.imageBackend = if workarounds then "kitty" else "sixel";
          sharedEditor.quartoSyncPackage =
            if workarounds then
              pkgs.vimUtils.buildVimPlugin {
                pname = "quarto-sync-fixture";
                version = "1";
                src = ../../tests/fixtures/quarto-sync;
              }
            else
              null;
        })
      ];
    };
  stable = make inputs.home-manager inputs.nixpkgs inputs.nixvim false;
  unstable = make inputs.consumer-home-manager inputs.consumer-nixpkgs inputs.consumer-nixvim true;
  check =
    pkgs: consumer:
    let
      c = consumer.config;
    in
    assert c.programs.git.settings.user.email == "consumer@example.invalid";
    assert c.programs.nixvim.globals.consumer_extension;
    assert builtins.length c.programs.nixvim.plugins.obsidian.settings.workspaces == 1;
    assert !(c.services.syncthing.enable or false);
    assert !(c.services.ollama.enable or false);
    assert !(c.wayland.windowManager.hyprland.enable or false);
    pkgs.runCommand "shared-feature-contract" { nativeBuildInputs = [ pkgs.git ]; } ''
      config=${c.xdg.configFile."git/config".source}
      test "$(git config --file "$config" --get alias.s)" = 'status -sb'
      test "$(git config --file "$config" --get pull.rebase)" = true
      test "$(git config --file "$config" --get rebase.autoStash)" = true
      test "$(git config --file "$config" --get init.defaultBranch)" = main
      test "$(git config --file "$config" --get user.email)" = consumer@example.invalid
      test -n "$(git config --file "$config" --get core.pager)"
      if git config --file "$config" --name-only --list | grep -Ei '^(extraconfig|aliases)\.'; then exit 1; fi
      touch "$out"
    '';
  editorCheck =
    pkgs: consumer: workFixture:
    let
      lib = inputs.nixpkgs.lib;
      c = consumer.config;
      testPython = consumer.pkgs.python3.withPackages (ps: [ ps.pytest ]);
      files = lib.filterAttrs (name: value: lib.hasPrefix "nvim/" name && value.enable) c.xdg.configFile;
      links = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: value: ''
          target="$XDG_CONFIG_HOME"/${lib.escapeShellArg name}
          mkdir -p "$(dirname "$target")"
          ln -s ${value.source} "$target"
        '') files
      );
      runTest = file: ''
        ${c.programs.nixvim.build.package}/bin/nvim --headless -u "$XDG_CONFIG_HOME/nvim/init.lua" \
          "+lua local ok, err = pcall(dofile, '${file}'); if not ok then print(err); vim.cmd('cquit 1') end" +qa!
      '';
    in
    pkgs.runCommand "shared-editor-headless"
      {
        nativeBuildInputs = [
          consumer.pkgs.direnv
          consumer.pkgs.just
          consumer.pkgs.python3Packages.nox
          consumer.pkgs.cargo
          consumer.pkgs.cargo-nextest
          consumer.pkgs.rustc
          consumer.pkgs.stdenv.cc
        ];
      }
      ''
          export XDG_CONFIG_HOME="$TMPDIR/config"
          export XDG_DATA_HOME="$TMPDIR/data"
          export XDG_STATE_HOME="$TMPDIR/state"
          export XDG_CACHE_HOME="$TMPDIR/cache"
          export NVIM_LOG_FILE="$TMPDIR/nvim.log"
          export NIXVIM_TEST_DIR="$TMPDIR/project"
          export NIXVIM_EDITOR_ASSETS=${../../assets/editor}
        export NIXVIM_TEST_PYTHON=${testPython}/bin/python3
        export NIXVIM_REMOVE=base
          export CARGO_HOME="$TMPDIR/cargo"
          mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME/nvim" "$XDG_STATE_HOME/nvim" "$XDG_CACHE_HOME/nvim" "$NIXVIM_TEST_DIR"
          ${links}
          ${runTest ../../tests/nixvim-composition.lua}
          ${runTest ../../tests/nixvim-overseer.lua}
          ${runTest ../../tests/nixvim-just.lua}
          ${runTest ../../tests/nixvim-python-env.lua}
          ${runTest ../../tests/nixvim-python-tools.lua}
          ${runTest ../../tests/nixvim-jupytext-safe.lua}
          ${runTest ../../tests/nixvim-rust-adapter.lua}
        ${runTest ../../tests/nixvim-neotest-project.lua}
          ${lib.optionalString workFixture (runTest ../../tests/nixvim-quarto-full.lua)}
          ${c.programs.nixvim.build.package}/bin/nvim --headless -u NONE -i NONE -l ${../../tests/nixvim-notebook.lua}
          ${c.programs.nixvim.build.package}/bin/nvim --headless -u NONE -i NONE -l ${../../tests/nixvim-project-env.lua}
          ${c.programs.nixvim.build.package}/bin/nvim --headless -u NONE -i NONE -l ${../../tests/nixvim-project-env-real.lua}
          ${c.programs.nixvim.build.package}/bin/nvim --headless -u NONE -i NONE -l ${../../tests/nixvim-python.lua}
          touch "$out"
      '';
in
{
  flake.homeConfigurations = {
    shared-stable = stable;
    shared-unstable = unstable;
  };
  perSystem = { pkgs, ... }: {
    checks = {
      shared-stable = check pkgs stable;
      shared-unstable = check pkgs unstable;
      shared-stable-build = stable.activationPackage;
      shared-unstable-build = unstable.activationPackage;
      shared-stable-editor = editorCheck pkgs stable false;
      shared-unstable-editor = editorCheck pkgs unstable true;
    };
  };
}

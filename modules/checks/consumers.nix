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
        {
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
        }
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
    };
  };
}

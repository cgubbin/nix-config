{
  inputs,
  config,
  lib,
  ...
}:
let
  make =
    manager: packages:
    manager.lib.homeManagerConfiguration {
      pkgs = import packages { system = "x86_64-linux"; };
      modules = [
        config.flake.modules.homeManager.shared-doom-emacs
        {
          home.username = "consumer";
          home.homeDirectory = "/home/consumer";
          home.stateVersion = "26.05";
          knowledge.orgDirectory = "/home/consumer/notes/work";
          knowledge.enableDaemon = false;
        }
      ];
    };
  stable = make inputs.home-manager inputs.nixpkgs;
  unstable = make inputs.consumer-home-manager inputs.consumer-nixpkgs;
  # Org is eagerly preloaded by Doom's Org-roam integration. The sandbox needs
  # a writable configured root before init, rather than changing it afterwards.
  smoke = stable.extendModules {
    modules = [ { knowledge.orgDirectory = lib.mkForce "/build/home/notes"; } ];
  };
  unselected = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
    modules = [
      {
        home.username = "consumer";
        home.homeDirectory = "/home/consumer";
        home.stateVersion = "26.05";
      }
    ];
  };
in
{
  options.flake.homeConfigurations = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
    description = "Independently buildable Home Manager consumer fixtures.";
  };
  config.flake.homeConfigurations = {
    doom-stable = stable;
    doom-unstable = unstable;
  };
  config.perSystem = { pkgs, ... }: {
    packages.doom-emacs = stable.config.programs.doom-emacs.finalEmacsPackage;
    checks = {
      doom-stable-build = stable.activationPackage;
      doom-unstable-build = unstable.activationPackage;
      doom-contract =
        assert stable.config.programs.doom-emacs.enable;
        assert unstable.config.programs.doom-emacs.enable;
        assert !stable.config.programs.emacs.enable;
        assert !stable.config.services.emacs.enable;
        assert lib.all (
          p:
          !(builtins.elem (lib.getName p) [
            "org-capture"
            "org-agenda"
            "org-notes"
          ])
        ) stable.config.home.packages;
        assert !stable.options.knowledge.orgDirectory.type.check "relative/notes";
        assert !stable.options.knowledge.orgDirectory.type.check "/nix/store/notes";
        assert !(unselected.config.services.emacs.enable or false);
        assert !(unselected.options.programs ? doom-emacs);
        pkgs.runCommand "doom-contract" { } ''touch "$out"'';
      doom-startup =
        pkgs.runCommand "doom-startup"
          {
            nativeBuildInputs = [
              pkgs.python3
              pkgs.uv
              pkgs.pixi
            ];
          }
          ''
            export HOME="$TMPDIR/home"
            export XDG_RUNTIME_DIR="$TMPDIR/runtime"
            export XDG_CACHE_HOME="$HOME/.cache"
            export XDG_STATE_HOME="$HOME/.local/state"
            export DOOMLOCALDIR="$XDG_STATE_HOME/doom/"
            mkdir -p "$HOME" "$XDG_RUNTIME_DIR" "$DOOMLOCALDIR"
            cp -R ${../../docs/examples/scientific} "$HOME/scientific-example"
            chmod -R u+w "$HOME/scientific-example"
            chmod 700 "$XDG_RUNTIME_DIR"
            app=${smoke.config.programs.doom-emacs.finalEmacsPackage}/bin
            "$app/emacs" --fg-daemon="$XDG_RUNTIME_DIR/server" > daemon.log 2>&1 &
            daemon=$!
            trap 'kill "$daemon" 2>/dev/null || true' EXIT
            ready=false
            for i in $(seq 1 120); do
              if "$app/emacsclient" -s "$XDG_RUNTIME_DIR/server" -e t > /dev/null 2>&1; then
                ready=true
                break
              fi
              kill -0 "$daemon" || { cat daemon.log; exit 1; }
              sleep 0.5
            done
            if ! "$ready"; then cat daemon.log; exit 1; fi
            "$app/emacsclient" -s "$XDG_RUNTIME_DIR/server" -e '(load "${../../tests/doom}/startup.el" nil nil t)' > result
            grep -qx t result || { cat result daemon.log; exit 1; }
            "$app/emacsclient" -s "$XDG_RUNTIME_DIR/server" -e '(kill-emacs)' || true
            wait "$daemon"
            touch "$out"
          '';
    };
  };
}

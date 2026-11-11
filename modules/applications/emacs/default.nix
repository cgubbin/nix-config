{ inputs, ... }:
{
  flake.modules.homeManager.shared-doom-emacs =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.knowledge;
      emacs = config.programs.doom-emacs.finalEmacsPackage;
      tex = pkgs.texlive.withPackages (p: [
        p.scheme-basic
        p.latex
        p.amsmath
        p.amsfonts
        p.graphics
        p.ulem
        p.dvips
        p.dvisvgm
        p.latexmk
        p.biblatex
        p.lm
        p.wrapfig
        p.capt-of
      ]);
      commands =
        map
          (
            action:
            pkgs.writeShellApplication {
              name = "org-${action}";
              runtimeInputs = [
                pkgs.coreutils
                pkgs.util-linux
                pkgs.systemd
                pkgs.jq
                pkgs.git
              ];
              text = ''
                action=${lib.escapeShellArg action}
                client=${emacs}/bin/emacsclient
                terminalClient=${lib.boolToString (!cfg.enableGraphicalIntegration)}
              ''
              + builtins.readFile ./scripts/org-client.sh;
            }
          )
          [
            "capture"
            "agenda"
            "notes"
            "project-capture"
            "project-todo"
            "project-agenda"
          ];
      doomDir = pkgs.runCommand "doom-config" { } ''
        mkdir -p "$out"
        cp ${./doom}/* "$out/"
        cat > "$out/host.el" <<'EOF'
        (setq org-directory ${builtins.toJSON cfg.orgDirectory})
        EOF
      '';
    in
    {
      imports = [ inputs.doom-emacs.homeModule ];
      options.knowledge = {
        orgDirectory = lib.mkOption {
          type = lib.types.addCheck lib.types.str (
            v: lib.hasPrefix "/" v && v != "/nix/store" && !(lib.hasPrefix "/nix/store/" v)
          );
          default = "${config.home.homeDirectory}/notes";
          description = "Absolute writable Org root; note contents are never managed by Nix.";
        };
        enableDaemon = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable the managed Emacs daemon and Org launch commands.";
        };
        enableGraphicalIntegration = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Start with the graphical session and add supported desktop entrypoints.";
        };
      };
      config = {
        assertions = [
          {
            assertion = pkgs.stdenv.hostPlatform.isLinux;
            message = "shared-doom-emacs currently supports Linux consumers.";
          }
        ];
        programs.doom-emacs = {
          enable = true;
          inherit doomDir;
          emacs = pkgs.emacs-pgtk;
          doomLocalDir = "${config.xdg.stateHome}/doom";
          extraPackages = epkgs: [
            epkgs.citar
            epkgs.catppuccin-theme
            epkgs.org-project-capture
            epkgs.org-projectile
            epkgs.projectile
          ];
          extraBinPackages = [
            pkgs.git
            pkgs.ripgrep
            pkgs.fd
            pkgs.biber
            pkgs.librsvg
            tex
          ];
        };
        services.emacs = lib.mkIf cfg.enableDaemon {
          enable = true;
          defaultEditor = false;
          client.enable = true;
          startWithUserSession = if cfg.enableGraphicalIntegration then "graphical" else false;
        };
        systemd.user.services.emacs = lib.mkIf cfg.enableDaemon {
          Service = {
            # Terminal-only consumers must not inherit stale WSLg variables
            # from the user manager. Graphical consumers retain session data.
            ExecStart = lib.mkForce "${emacs}/bin/emacs --fg-daemon=%t/emacs/server";
            UnsetEnvironment = lib.optionals (!cfg.enableGraphicalIntegration) [
              "DISPLAY"
              "WAYLAND_DISPLAY"
              "GDK_BACKEND"
              "XAUTHORITY"
            ];
            RuntimeDirectory = "emacs";
            RuntimeDirectoryMode = "0700";
            TimeoutStartSec = 60;
          };
        };
        home.packages = lib.optionals cfg.enableDaemon commands;
        wayland.windowManager.hyprland.settings.bind =
          lib.mkIf
            (cfg.enableDaemon && cfg.enableGraphicalIntegration && config.wayland.windowManager.hyprland.enable)
            [
              "SUPER SHIFT,O,exec,${lib.getExe (builtins.elemAt commands 0)}"
              "SUPER SHIFT,A,exec,${lib.getExe (builtins.elemAt commands 1)}"
            ];
      };
    };
}

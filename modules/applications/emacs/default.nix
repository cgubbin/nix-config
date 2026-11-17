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
      orgOpenPdf = pkgs.writeShellApplication {
        name = "org-open-pdf";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.zathura
        ];
        text = builtins.readFile ./scripts/org-open-pdf.sh;
      };
      # Shows an image in a terminal pane; Org opens it in Zellij from terminal frames.
      orgViewImage = pkgs.writeShellApplication {
        name = "org-view-image";
        runtimeInputs = [
          pkgs.chafa
          pkgs.coreutils
        ];
        text = builtins.readFile ./scripts/org-view-image.sh;
      };
      # The terminal's image protocol, shared with image.nvim when the consumer imports
      # shared-editor; sixel otherwise. A terminal pane cannot use ueberzug, so it gets
      # character art.
      imageProtocol =
        {
          sixel = "sixels";
          kitty = "kitty";
          ueberzug = "symbols";
        }
        .${lib.attrByPath [ "sharedEditor" "imageBackend" ] "sixel" config};
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
      # Conda-forge binaries that pixi installs expect a standard Linux filesystem; the FHS wrapper
      # provides it on NixOS. Babel blocks run `pixi run --as-is python` from Emacs (learning notes).
      pixi = pkgs.buildFHSEnv {
        name = "pixi";
        runScript = "pixi";
        targetPkgs = p: [ p.pixi ];
      };
      doomDir = pkgs.runCommand "doom-config" { } ''
        mkdir -p "$out"
        cp ${./doom}/* "$out/"
        cat > "$out/host.el" <<'EOF'
        (setq org-directory ${builtins.toJSON cfg.orgDirectory})
        (setq kit/org-image-viewer ${builtins.toJSON "${orgViewImage}/bin/org-view-image"}
              kit/org-image-protocol ${builtins.toJSON imageProtocol})
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
            epkgs.forge
            epkgs.org-download
            epkgs.org-noter
            epkgs.org-project-capture
            epkgs.org-projectile
            epkgs.pdf-tools
            epkgs.projectile
          ];
          extraBinPackages = [
            pkgs.git
            pkgs.ripgrep
            pkgs.fd
            pkgs.biber
            pkgs.librsvg
            pkgs.zathura
            pixi
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
            # A daemon decides tty colour depth from its own environment, not
            # the client's. Terminal-only consumers otherwise get themes
            # quantized to 256 colours.
            Environment = lib.optionals (!cfg.enableGraphicalIntegration) [ "COLORTERM=truecolor" ];
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
        home.packages = [ pixi ] ++ lib.optionals cfg.enableDaemon (commands ++ [ orgOpenPdf ]);
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

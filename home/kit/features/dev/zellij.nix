{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.home-config.dev;
in {
  programs.zellij = mkIf cfg.devTools.enable {
    enable = true;
    enableFishIntegration = false;
  };

  # NOTE: the module only supports YAML config which is deprecated
  home.file.zellij = mkIf cfg.devTools.enable {
    target = ".config/zellij/config.kdl";
    text = ''
      keybinds {
          normal clear-defaults=true {
              // tmux
              bind "Ctrl b" { SwitchToMode "Tmux"; }
          }

          tmux clear-defaults=true {
              bind "Ctrl b" { Write 2; SwitchToMode "Normal"; }
              bind "Esc" { SwitchToMode "Normal"; }
              bind "g" { SwitchToMode "Locked"; }
              bind "p" { SwitchToMode "Pane"; }
              bind "t" { SwitchToMode "Tab"; }
              bind "n" { SwitchToMode "Resize"; }
              bind "h" { SwitchToMode "Move"; }
              bind "s" { SwitchToMode "Scroll"; }
              bind "o" { SwitchToMode "Session"; }
              bind "q" { Quit; }
          }
      }

      theme "tokyo-night-dark"

      themes {
        tokyo-night-dark {
            fg 169 177 214
            bg 26 27 38
            black 56 62 90
            red 249 51 87
            green 158 206 106
            yellow 224 175 104
            blue 122 162 247
            magenta 187 154 247
            cyan 42 195 222
            white 192 202 245
            orange 255 158 100
        }

        catppuccin-mocha {
            bg "#585b70" // Surface2
            fg "#cdd6f4" // Text
            red "#f38ba8"
            green "#a6e3a1"
            blue "#89b4fa"
            yellow "#f9e2af"
            magenta "#f5c2e7" // Pink
            orange "#fab387" // Peach
            cyan "#89dceb" // Sky
            black "#181825" // Mantle
            white "#cdd6f4" // Text
        }
      }
    '';
  };

  xdg.configFile."zellij/layouts/default.kdl".text = ''
    layout {
      tab name="code" {
        pane command="nvim" size="70%"
        pane split_direction="vertical" size="30%" {
          pane name="shell"
          pane name="tasks"
        }
      }
      tab name="git" {
        pane split_direction="vertical" {
          pane name="status"
          pane name="shell"
        }
      }
    }
  '';

  xdg.configFile."zellij/layouts/nix.kdl".text = ''
    layout {
      tab name="nix" {
        pane command="nvim" size="68%"
        pane split_direction="vertical" size="32%" {
          pane name="build"
          pane name="ops"
        }
      }
      tab name="git" {
        pane split_direction="vertical" {
          pane name="status"
          pane name="shell"
        }
      }
    }
  '';

  xdg.configFile."zellij/layouts/python.kdl".text = ''
    layout {
      tab name="code" {
        pane command="nvim" size="70%"
        pane split_direction="vertical" size="30%" {
          pane name="shell"
          pane name="tests"
        }
      }
      tab name="git" {
        pane split_direction="vertical" {
          pane name="status"
          pane name="notes"
        }
      }
    }
  '';

  xdg.configFile."zellij/layouts/rust.kdl".text = ''
    layout {
      tab name="code" {
        pane command="nvim" size="65%"
        pane split_direction="vertical" size="35%" {
          pane name="build"
          pane name="run"
        }
      }
      tab name="git" {
        pane split_direction="vertical" {
          pane name="status"
          pane name="shell"
        }
      }
    }
  '';

  xdg.configFile."zellij/layouts/latex.kdl".text = ''
    layout {
      tab name="write" {
        pane command="nvim" size="72%"
        pane split_direction="vertical" size="28%" {
          pane name="render"
          pane name="shell"
        }
      }
      tab name="refs" {
        pane split_direction="vertical" {
          pane name="notes"
          pane name="shell"
        }
      }
    }
  '';

  xdg.configFile."zellij/layouts/quarto.kdl".text = ''
    layout {
      tab name="write" {
        pane command="nvim" size="72%"
        pane split_direction="vertical" size="28%" {
          pane name="render"
          pane name="shell"
        }
      }
      tab name="refs" {
        pane split_direction="vertical" {
          pane name="notes"
          pane name="shell"
        }
      }
    }
  '';
}

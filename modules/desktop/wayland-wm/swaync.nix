_: {
  flake.modules.homeManager."home-kit-features-desktop-wayland-wm-swaync" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib) mkIf;
      cfg = config.home-config.desktop;
      enabled = pkgs.stdenv.isLinux && cfg.wayland.enable;
    in
    {
      config = mkIf enabled (
        let
          colors = config.lib.stylix.colors;
          background = "#" + colors.base00;
          selBackground = "#" + colors.base03;
          text = "#" + colors.base05;
          urgent = "#" + colors.base09;
          border = "#" + colors.base0D;
        in
        {
          systemd.user.services.swaync = {
            Unit = {
              Description = "Swaync notification daemon";
              Documentation = "https://github.com/ErikReider/SwayNotificationCenter";
              After = [ "graphical-session.target" ];
              PartOf = [ "graphical-session.target" ];
            };

            Service = {
              Type = "dbus";
              BusName = "org.freedesktop.Notifications";
              ExecStart = lib.getExe pkgs.swaynotificationcenter;
              Restart = "on-failure";
            };

            Install.WantedBy = [ "graphical-session.target" ];
          };

          home.file.".config/swaync/config.json".text = ''
            {
              "positionX": "right",
              "positionY": "top",
              "layer": "overlay",
              "control-center-layer": "top",
              "layer-shell": true,
              "cssPriority": "application",
              "control-center-margin-top": 0,
              "control-center-margin-bottom": 0,
              "control-center-margin-right": 0,
              "control-center-margin-left": 0,
              "notification-2fa-action": true,
              "notification-inline-replies": true,
              "notification-icon-size": 64,
              "notification-body-image-height": 100,
              "notification-body-image-width": 200,
              "timeout": 10,
              "timeout-low": 5,
              "timeout-critical": 0,
              "fit-to-screen": true,
              "relative-timestamps": true,
              "control-center-width": 500,
              "control-center-height": 600,
              "notification-window-width": 500,
              "keyboard-shortcuts": true,
              "image-visibility": "when-available",
              "transition-time": 200,
              "hide-on-clear": true,
              "hide-on-action": true,
              "script-fail-notify": true,
              "notification-visibility": {
                "sonixd": {
                  "state": "muted",
                  "urgency": "Low",
                  "app-name": "Sonixd"
                }
              },
              "widgets": [
                "title",
                "notifications"
              ],
              "widget-config": {
                "inhibitors": {
                  "text": "Inhibitors",
                  "button-text": "Clear All",
                  "clear-all-button": true
                },
                "title": {
                  "text": "",
                  "clear-all-button": true,
                  "button-text": "󰆴 Clear All"
                },
                "dnd": {
                  "text": ""
                },
                "volume": {
                  "show-per-app": true,
                  "show-per-app-label": true
                },
                "buttons-grid": {
                  "actions": [
                    {
                      "label": "󰌾",
                      "command": "${pkgs.hyprlock}/bin/hyprlock"
                    },
                    {
                      "label": "󰍃",
                      "command": "${pkgs.wlogout}/bin/wlogout"
                    },
                    {
                      "label": "󰕾",
                      "command": "${pkgs.ponymix}/bin/ponymix toggle"
                    },
                    {
                      "label": "󰖩",
                      "command": "${pkgs.alacritty}/bin/alacritty -e ${pkgs.networkmanager}/bin/nmtui"
                    },
                    {
                      "label": "󰂯",
                      "command": "${pkgs.blueman}/bin/blueman-manager"
                    }
                  ]
                }
              }
            }
          '';

          home.file.".config/swaync/style.css".text = ''
            @define-color noti-border-color ${border};
            @define-color noti-bg ${background};
            @define-color noti-bg-darker ${background};
            @define-color noti-bg-hover ${selBackground};
            @define-color noti-bg-focus ${selBackground};
            @define-color noti-close-bg ${background};
            @define-color noti-close-bg-hover ${background};

            @define-color text-color ${text};
            @define-color text-color-disabled ${text};

            @define-color bg-selected ${selBackground};

            .critical {
              background: ${urgent};
              padding: 6px;
              border-radius: 12px;
            }
          '';
        }
      );
    };
}

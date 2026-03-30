{ lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
in
{
  options.home-config = {
    cli = {
      commonTools.enable = mkEnableOption ''
        Enable common CLI Tools
      '';
      nvTop.enable = mkEnableOption ''
        Enable nvTop
      '';

      VPNC.enable = mkEnableOption ''
        Enable VPNC
      '';

      syncthing = {
        enable = mkEnableOption ''
          Enable Syncthing
        '';

        localKeyDirName = mkOption {
          type = types.str;
        };

        devices = mkOption {
          type = types.attrsOf types.str;
          default = { };
          example = {
            kitsune = "DEVICE-ID-1";
            macbook = "DEVICE-ID-2";
          };
        };

        folders = mkOption {
          type = types.attrsOf (
            types.submodule {
              options = {
                label = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                };

                path = mkOption {
                  type = types.str;
                };

                devices = mkOption {
                  type = types.listOf types.str;
                  default = [ ];
                };

                versioning = mkOption {
                  type = types.attrs;
                  default = {
                    type = "simple";
                    params = {
                      keep = "10";
                      cleanoutDays = "0";
                    };
                  };
                };
              };
            }
          );
          default = { };
        };

      };
    };

    gui = {
      kitty.enable = mkEnableOption ''
        Enable Kitty
      '';

      firefox = {
        enable = mkEnableOption ''
          Enable Firefox
        '';
        searxngInstance = {
          local = mkEnableOption ''Self-host Searxng or not'';
          url = mkOption {
            type = lib.types.str;
            default = "https://searxng.brihx.fr";
            description = ''
              URL for searxng instance
            '';
          };
          port = mkOption {
            type = lib.types.int;
            default = 443;
            description = ''
              Port for searxng instance
            '';
          };
        };

        homepageUrl = mkOption {
          type = lib.types.str;
          default = "about:blank";
          description = ''
            URL for firefox homepage
          '';
        };
      };

      social.enable = mkEnableOption ''
        Enable Social (Discord, Beeper)
      '';

      utils.enable = mkEnableOption ''
        Enable common GUI Tools
      '';

      ai = {
        lmstudio.enable = mkEnableOption ''
          Enable LMStudio
        '';

        comfyUI.enable = mkEnableOption ''
          Enable ComfyUI (from nix-ai-stuff flake)
        '';
      };
    };

    dev = {
      vscode.enable = mkEnableOption ''
        Enabe VsCode
      '';

      jetbrains.enable = mkEnableOption ''
        Enable Jetbrains
      '';

      devTools.enable = mkEnableOption ''
        Enable common Dev Tools
      '';
    };

    custom-fonts = {
      berkeleyMono.enable = mkEnableOption ''
        Enable Berkeley Mono
      '';

      dankMono.enable = mkEnableOption ''
        Enable Dank Mono
      '';

      etBembo.enable = mkEnableOption ''
        Enable ET Bembo
      '';

      jetBrainsMono.enable = mkEnableOption ''
        Enable Jet Brains Mono
      '';

      symbolsMono.enable = mkEnableOption ''
        Enable Symbols Mono
      '';
    };

    desktop = {
      wayland = {

        enable = mkEnableOption ''Enable Wayland Window Manager'';
        niri = {
          enable = mkEnableOption ''Enable Niri'';
          brokenAudioMuteKey = mkEnableOption ''How did I even break this'';
        };

        hyprland = {
          enable = mkEnableOption ''
            Enable Hyprland
          '';
          nvidia = mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Enable Nvidia options for Hyprland
            '';
          };
        };
        hypridleConfig = {
          screenDimTime = mkOption {
            type = lib.types.ints.u32;
            default = 1800;
            description = "Screen dim time in seconds";
          };
          lockTime = mkOption {
            type = lib.types.ints.u32;
            default = 3600;
            description = "Lock time in seconds";
          };

          suspendTime = mkOption {
            type = lib.types.ints.u32;
            default = 7200;
            description = "Suspend time in seconds";
          };
        };

        waybarConfig = {
          batteryName = mkOption {
            type = lib.types.str;
            default = "BAT0";
            description = "Battery filename as in /sys/class/powwer_supply/BATx";
          };
        };
      };

      gnome.enable = mkEnableOption ''
        Enable Gnome
      '';

    };

    theme = {
      stylix.enable = mkEnableOption ''
        Enable stylix (if enabled in NixOS config)
      '';
    };

    misc = {
      nextcloud = {
        enable = mkEnableOption ''
          Enable Nextcloud desktop client
        '';
      };
    };
    gaming.enable = mkEnableOption ''
      Enable Gaming
    '';

    virtualization.enable = mkEnableOption ''
      Enable Virtualization
    '';
  };
}

{ config, ... }:
let
  top = config;
in
{
  flake.modules.homeManager."home-kit-kitsune" = { ... }: {
    services.syncthing.settings.devices = {
      pi5.addresses = [
        "tcp://192.168.1.3:22000"
        "tcp://100.80.21.7:22000"
      ];
      # Preserve the legacy entry without resuming an unverified phone pairing.
      iphone.paused = true;
    };

    imports = [
      top.flake.modules.homeManager."home-kit-features"
      top.flake.modules.homeManager."home-kit-global"
    ];

    home-config = {
      desktop = {
        wayland = {
          enable = true;
          hyprland = {
            enable = true;
            nvidia = true;
          };
        };
      };

      theme = {
        stylix.enable = true;
      };
      custom-fonts = {
        berkeleyMono.enable = true;
        dankMono.enable = true;
      };
      gaming.enable = true;
      gui = {
        kitty.enable = true;
        firefox = {
          enable = true;
        };
        utils.enable = true;
      };
      dev.devTools.enable = true;
      cli = {
        nvTop.enable = true;
        syncthing = {
          enable = true;
          localKeyDirName = "workstation";
          useIdentityFiles = false;
          devices = {
            kitsune = "HXOHUD3-C6C4SU6-DMAPHVY-XCENNLS-EZ4WETQ-X45DESC-MSJ567J-MUCF5QF";
            pi5 = "VHKCIED-Z7O6YB6-A2IPY3A-IYYUY7Z-25GK4BN-AAPJT62-FV6GWS4-SMJX6QI";
            iphone = "R4O26BK-AQAQMV4-WEVYSWD-2CNV6KN-JWTU7JA-36MDCL6-KEBPTVO-6O2P6AX";
          };
          folders = {
            obsidian = {
              path = "obsidian";
              devices = [
                "kitsune"
                "iphone"
                "pi5"
              ];
            };
            pi-media = {
              path = "/mnt/Media/pi";
              type = "sendonly";
              devices = [ "pi5" ];
              versioning = null;
            };
            books = {
              path = "books";
              devices = [
                "kitsune"
              ];
            };
          };
        };
      };
    };

    monitors = [
      {
        name = "eDP-1";
        width = 3840;
        height = 2400;
        refreshRate = 60.0;
        scale = 1.5;
        x = 0;
        workspace = "1";
        primary = true;
      }
      {
        name = "DP-5";
        width = 2560;
        height = 1440;
        refreshRate = 59.95;
        scale = 1.0;
        x = 2560;
        workspace = "2";
      }
      {
        name = "DP-6";
        width = 3840;
        height = 2160;
        refreshRate = 30.0;
        scale = 1.5;
        x = 5160;
        workspace = "3";
      }
    ];
  };
}

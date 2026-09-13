{...}: {
  imports = [
    ./features
    ./global
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
      commonTools.enable = true;
      nvTop.enable = true;
      syncthing = {
        enable = true;
        localKeyDirName = "workstation";
        devices = {
          kitsune = "HXOHUD3-C6C4SU6-DMAPHVY-XCENNLS-EZ4WETQ-X45DESC-MSJ567J-MUCF5QF";
          macbook = "BMVUX2J-YQOZ5G5-YR7FFDB-NBVFNUX-47KBBTR-3BSQ2TL-GAKVBY3-GFYDMA3";
          iphone = "R4O26BK-AQAQMV4-WEVYSWD-2CNV6KN-JWTU7JA-36MDCL6-KEBPTVO-6O2P6AX";
        };
        folders = {
          obsidian = {
            path = "obsidian";
            devices = [
              "kitsune"
              "macbook"
              "iphone"
            ];
          };
          books = {
            path = "books";
            devices = [
              "kitsune"
              "macbook"
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
}

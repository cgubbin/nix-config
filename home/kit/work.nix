{...}: {
  imports = [
    ./features
    ./global
  ];

  home-config = {
    desktop = {
      wayland = {
        enable = false;
        hyprland = {
          enable = false;
          nvidia = false;
        };
      };
    };

    theme = {
      stylix.enable = true;
    };
    custom-fonts = {
      dankMono.enable = true;
      berkeleyMono.enable = true;
    };
    gaming.enable = false;
    gui = {
      kitty.enable = false;
      firefox = {
        enable = false;
      };
      utils.enable = false;
    };
    dev.devTools.enable = true;
    cli = {
      commonTools.enable = true;
      nvTop.enable = false;
      syncthing = {
        enable = false;
      };
    };
  };
}

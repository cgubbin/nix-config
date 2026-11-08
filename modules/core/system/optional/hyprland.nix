_: {
  flake.modules.nixos."hosts-common-optional-hyprland" = { pkgs, ... }: {
    programs.hyprland = {
      xwayland.enable = true;
      withUWSM = true;
      enable = true;
    };

    xdg = {
      portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };
    };

    programs.hyprlock.enable = true;
    services.hypridle.enable = true;

    environment.systemPackages = with pkgs; [
      pyprland
      hyprland-qtutils
      hyprpicker
      hyprcursor
      hyprlock
      hypridle
      hyprpaper
      hyprsunset
      hyprpolkitagent
      kitty
    ];
  };
}

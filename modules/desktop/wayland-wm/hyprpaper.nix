_: {
  flake.modules.homeManager."home-kit-features-desktop-wayland-wm-hyprpaper" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib) mkIf;
      cfg = config.home-config.desktop;
      enabled = cfg.wayland.hyprland.enable && pkgs.stdenv.isLinux;
    in
    {
      config = mkIf enabled {
        services.hyprpaper.enable = true;
      };
    };
}

{ config, ... }:
let
  top = config;
in
{
  flake.modules.homeManager."home-kit-features-desktop-wayland-wm" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib) mkIf;
      cfg = config.home-config.desktop;
      enabled = cfg.wayland.enable && pkgs.stdenv.isLinux;
    in
    {
      imports = [
        top.flake.modules.homeManager."home-kit-features-desktop-wayland-wm-albert"
        top.flake.modules.homeManager."home-kit-features-desktop-wayland-wm-hypridle"
        top.flake.modules.homeManager."home-kit-features-desktop-wayland-wm-hyprlock"
        top.flake.modules.homeManager."home-kit-features-desktop-wayland-wm-hyprpaper"
        top.flake.modules.homeManager."home-kit-features-desktop-wayland-wm-swaync"
        top.flake.modules.homeManager."home-kit-features-desktop-wayland-wm-waybar"
      ];

      config = mkIf enabled {
        home.packages = with pkgs; [
          meson
          wayland-protocols
          wayland-utils
          wlroots
          copyq
          wl-clipboard
        ];
        services.playerctld.enable = true;
      };
    };
}

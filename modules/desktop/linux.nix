{ config, ... }:
let
  top = config;
in
{
  flake.modules.homeManager."home-kit-features-desktop-linux" =
    { ... }:
    {
      imports = [
        top.flake.modules.homeManager."home-kit-features-desktop-hyprland"
        top.flake.modules.homeManager."home-kit-features-desktop-darkman"
        top.flake.modules.homeManager."home-kit-features-desktop-wayland-wm"
      ];
    };
}

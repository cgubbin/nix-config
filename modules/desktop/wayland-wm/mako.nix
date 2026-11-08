_: {
  flake.modules.homeManager."home-kit-features-desktop-wayland-wm-mako" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # inherit (config.colorScheme) palette kind;

      inherit (lib) mkIf;
      cfg = config.home-config.desktop.wayland;
      enabled = pkgs.stdenv.isLinux && cfg.hyprland.enable;
    in
    {
      services.mako = mkIf enabled {
        enable = true;

        # iconPath =
        #   if kind == "dark" then
        #     "${config.gtk.iconTheme.package}/share/icons/Papirus-Dark"
        #   else
        #     "${config.gtk.iconTheme.package}/share/icons/Papirus-Light";
        # font = "${config.fontProfiles.regular.family} 12";
        settings = {
          padding = "10,20";
          anchor = "top-center";
          width = 400;
          height = 150;
          border-size = 2;
          default-timeout = 12000;
          # backgroundColor = "#${palette.base00}dd";
          # borderColor = "#${palette.palettebase03}dd";
          # textColor = "#${palette.base05}dd";
          layer = "overlay";
        };
      };
    };
}

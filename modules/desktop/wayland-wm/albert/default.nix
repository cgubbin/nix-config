_: {
  flake.modules.homeManager."home-kit-features-desktop-wayland-wm-albert" =
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
      config = mkIf enabled {
        home = {
          sessionVariables.GOLDENDICT_FORCE_WAYLAND = "1";
          packages = [
            pkgs.goldendict-ng
            pkgs.libnotify
            pkgs.master.albert
          ];
        };

        xdg.configFile."albert/config".source = ./../../../../assets/albert/config.toml;
        xdg.configFile."albert/websearch/engines.json".source =
          ./../../../../assets/albert/websearch-engines.json;
        xdg.configFile."autostart/albert.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=Albert
          Comment=Application launcher
          Exec=albert
          Terminal=false
          Categories=Utility;
          X-GNOME-Autostart-enabled=true
        '';
        # xdg.configFile = {
        #   "albert/config".source = config.lib.file.mkOutOfStoreSymlink "${toString dir}/config.toml";
        #   "albert/websearch/engines.json".source =
        #     config.lib.file.mkOutOfStoreSymlink "${toString dir}/websearch-engines.json";
        # };
      };
    };
}

_: {
  flake.modules.homeManager."home-kit-features-gui-kitty" =
    {
      config,
      lib,
      ...
    }:
    let
      inherit (lib) mkIf;
      cfg = config.home-config.gui;
    in
    {
      stylix.targets.kitty.enable = true;
      programs.kitty = mkIf cfg.kitty.enable {
        enable = true;
        settings = {
          scrollback_lines = 4000;
          scrollback_pager_history_size = 2048;
          window_padding_width = 15;
        };
      };
    };
}

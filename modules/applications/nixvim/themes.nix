_: {
  flake.modules.homeManager."home-kit-global-tools-nixvim-themes" = _: {
    programs.nixvim = {
      colorschemes = {
        tokyonight = {
          enable = true;
          settings = {
            style = "storm";
            light_style = "day";
            transparent = false;
            terminal_colors = true;
            styles = {
              comments.italic = true;
              keywords.italic = true;
              functions = { };
              variables = { };
              sidebars = "dark";
              floats = "dark";
            };
            day_brightness = 0.3;
            hide_inactive_statusline = false;
            dim_inactive = true;
            lualine_bold = true;
          };
        };
      };
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf optionalAttrs hasAttrByPath;
  cfg = config.home-config.cli;
  hasStylix = hasAttrByPath [ "home-config" "desktop" "stylix" "enable" ] config;
  stylixEnabled = hasStylix && config.home-config.theme.stylix.enable;
in
{
  programs.bottom = mkIf cfg.commonTools.enable {
    enable = true;
    settings = {
      flags = {
        battery = true;
        color = "default-light";
        tree = true;
        enable_cache_memory = true;
      };
    }
    // optionalAttrs stylixEnabled {
      colors = with config.lib.stylix.colors; {
        table_header_color = "#${base06}";
        all_cpu_color = "#${base06}";
        avg_cpu_color = "#${base0F}";
        cpu_core_colors = [
          "#${base08}"
          "#${base09}"
          "#${base0A}"
          "#${base0B}"
          "#${base0D}"
          "#${base0E}"
        ];
        ram_color = "#${base0B}";
        swap_color = "#${base09}";
        rx_color = "#${base0B}";
        tx_color = "#${base08}";
        widget_title_color = "#${base06}";
        border_color = "#${base01}";
        highlighted_border_color = "#${base0F}";
        text_color = "#${base05}";
        graph_color = "#${base04}";
        cursor_color = "#${base0F}";
        selected_text_color = "#${base02}";
        selected_bg_color = "#${base0E}";
        high_battery_color = "#${base0B}";
        medium_battery_color = "#${base0A}";
        low_battery_color = "#${base08}";
        gpu_core_colors = [
          "#${base0D}"
          "#${base0E}"
          "#${base08}"
          "#${base09}"
          "#${base0A}"
          "#${base0B}"
        ];
        arc_color = "#${base0C}";
      };
    };
  };
}

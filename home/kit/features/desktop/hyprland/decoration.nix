{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.home-config.desktop.wayland;
in
{
  wayland.windowManager.hyprland.settings = mkIf cfg.hyprland.enable {
    general = {
      gaps_in = 5;
      gaps_out = 10;
      border_size = 2;
      layout = "dwindle";
      # col = {
      	# active_border = "$teal";
	# inactive_border = "$surface1";
      # };
    };

    decoration = {
      active_opacity = 0.8;
      inactive_opacity = 0.7;
      fullscreen_opacity = 0.8;
      rounding = 5;
      # blur = {
      #   enabled = true;
      #   size = 5;
      #   passes = 3;
      #   new_optimizations = true;
      #   ignore_opacity = true;
      # };
      shadow = {
        enabled = true;
        range = 12;
        offset = "0 0";
	# color = "$teal";
	# color_inactive = "0xff$baseAlpha";
      };
    };
    # layerrule = "blur, logout_dialog";
    animations = {
      enabled = true;
      bezier = [
        "easein,0.11, 0, 0.5, 0"
        "easeout,0.5, 1, 0.89, 1"
        "easeinback,0.36, 0, 0.66, -0.56"
        "easeoutback,0.34, 1.56, 0.64, 1"
      ];

      animation = [
        "windowsIn,1,3,easeoutback,slide"
        "windowsOut,1,3,easeinback,slide"
        "windowsMove,1,3,easeoutback"
        "workspaces,1,2,easeoutback,slide"
        "fadeIn,1,3,easeout"
        "fadeOut,1,3,easein"
        "fadeSwitch,1,3,easeout"
        "fadeShadow,1,3,easeout"
        "fadeDim,1,3,easeout"
        "border,1,3,easeout"
      ];
    };
    dwindle = {
	pseudotile = true;
    	preserve_split = true;
    	smart_split = true;
    };
  };
}

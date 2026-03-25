{
	lib,
	config,
	...
}:
let
	inherit (lib) mkIf;
	cfg = config.home-config.desktop.wayland;
  	workspaces = (map toString (lib.range 0 9)) ++ (map (n: "F${toString n}") (lib.range 1 12));
	# Map keys to hyprland directions
  	directions = rec {
    left = "l";
    right = "r";
    up = "u";
    down = "d";
    h = left;
    l = right;
    k = up;
    j = down;
  	};
in
{
	wayland.windowManager.hyprland.settings = mkIf cfg.hyprland.enable {
	bindm = [
      "SUPER,mouse:272,movewindow"
      "SUPER,mouse:273,resizewindow"
    ];
		bind =
      [
        "SUPERSHIFT,q,killactive"
        "SUPERSHIFT,e,exit"

        "SUPER,s,togglesplit"
        "SUPER,f,fullscreen,1"
        "SUPERSHIFT,f,fullscreen,0"
        "SUPERSHIFT,space,togglefloating"

        "SUPER,KP_Subtract,splitratio,-0.25"
        "SUPERSHIFT,KP_Subtract,splitratio,-0.3333333"

        "SUPER,KP_Add,splitratio,0.25"
        "SUPERSHIFT,KP_Add,splitratio,0.3333333"

        "SUPER,g,togglegroup"
        "SUPER,b,changegroupactive,f"
        "SUPERSHIFT,r,changegroupactive,r"

        "SUPERSHIFT,g,pin"

        "SUPER,u,togglespecialworkspace, U"
        "SUPERSHIFT,u,movetoworkspace,special:U"

        "SUPER,i,togglespecialworkspace, I"
        "SUPERSHIFT,i,movetoworkspace,special:I"

        "SUPER,o,togglespecialworkspace, O"
        "SUPERSHIFT,o,movetoworkspace,special:O"

        "SUPER, KP_End, workspace, 1"
        "SUPER, KP_Down, workspace, 2"
        "SUPER, KP_Next, workspace, 3"
        "SUPER, KP_Left, workspace, 4"
        "SUPER, KP_Begin, workspace, 5"
        "SUPER, KP_Right, workspace, 6"
        "SUPER, KP_Home, workspace, 7"
        "SUPER, KP_Up, workspace, 8"
        "SUPER, KP_Prior, workspace, 9"
        "SUPER, KP_Insert, workspace, 10" 

        "SUPERSHIFT, KP_End, movetoworkspace, 1"
        "SUPERSHIFT, KP_Down, movetoworkspace, 2"
        "SUPERSHIFT, KP_Next, movetoworkspace, 3"
        "SUPERSHIFT, KP_Left, movetoworkspace, 4"
        "SUPERSHIFT, KP_Begin, movetoworkspace, 5"
        "SUPERSHIFT, KP_Right, movetoworkspace, 6"
        "SUPERSHIFT, KP_Home, movetoworkspace, 7"
        "SUPERSHIFT, KP_Up, movetoworkspace, 8"
        "SUPERSHIFT, KP_Prior, movetoworkspace, 9"
        "SUPERSHIFT, KP_Insert, movetoworkspace, 10" 

      ]
      ++
        # Change workspace
        (map (n: "SUPER,${n},workspace,name:${n}") workspaces)
      ++
        # Move window to workspace
        (map (n: "SUPERSHIFT,${n},movetoworkspacesilent,name:${n}") workspaces)
      # Change workspace with numpad
      ++ (map (n: "SUPER,KP_${n},workspace,name:${n}") workspaces)
      ++
        # Move window to workspace with numpad
        (map (n: "SUPERSHIFT,KP_${n},movetoworkspacesilent,name:${n}") workspaces)
      ++
        # Move focus
        (lib.mapAttrsToList (key: direction: "SUPER,${key},movefocus,${direction}") directions)
      ++
        # Swap windows
        (lib.mapAttrsToList (key: direction: "SUPERSHIFT,${key},swapwindow,${direction}") directions)
      ++
        # Move monitor focus
        (lib.mapAttrsToList (key: direction: "SUPERCONTROL,${key},focusmonitor,${direction}") directions)
      ++
        # Move window to other monitor
        (lib.mapAttrsToList (
          key: direction: "SUPERCONTROLSHIFT,${key},movewindow,mon:${direction}"
        ) directions)
      ++
        # Move workspace to other monitor
        (lib.mapAttrsToList (
          key: direction: "SUPERALT,${key},movecurrentworkspacetomonitor,${direction}"
        ) directions);
	};
}

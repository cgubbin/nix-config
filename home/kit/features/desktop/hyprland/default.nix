{
	config,
	pkgs,
	lib,
    inputs,
	...
}:
let
	inherit (lib) mkIf;
	cfg = config.home-config.desktop.wayland;
in
{
	imports = [
		./bind.nix
		./decoration.nix
		./window-bind.nix
	];

	wayland.windowManager.hyprland = mkIf cfg.hyprland.enable {
		# Whether to enable Hyprland wayland compositor
		enable = true;

		# Whether to enable XWayland
		xwayland.enable = true;


		extraConfig = 
			let
				swaync = lib.getExe' pkgs.swaynotificationcenter "swaync";
				copyq = lib.getExe pkgs.copyq;
				albert = lib.getExe pkgs.albert;
			in
			''

windowrulev2 = float,class:(1Password)

exec-once = ${swaync};
exec-once = ${copyq};
exec-once = ${albert};

# Macchiato

$rosewater = rgb(f4dbd6)
$rosewaterAlpha = f4dbd6

$flamingo = rgb(f0c6c6)
$flamingoAlpha = f0c6c6

$pink = rgb(f5bde6)
$pinkAlpha = f5bde6

$mauve = rgb(c6a0f6)
$mauveAlpha = c6a0f6

$red = rgb(ed8796)
$redAlpha = ed8796

$maroon = rgb(ee99a0)
$maroonAlpha = ee99a0

$peach = rgb(f5a97f)
$peachAlpha = f5a97f

$yellow = rgb(eed49f)
$yellowAlpha = eed49f

$green = rgb(a6da95)
$greenAlpha = a6da95

$teal = rgb(8bd5ca)
$tealAlpha = 8bd5ca

$sky = rgb(91d7e3)
$skyAlpha = 91d7e3

$sapphire = rgb(7dc4e4)
$sapphireAlpha = 7dc4e4

$blue = rgb(8aadf4)
$blueAlpha = 8aadf4

$lavender = rgb(b7bdf8)
$lavenderAlpha = b7bdf8

$text = rgb(cad3f5)
$textAlpha = cad3f5

$subtext1 = rgb(b8c0e0)
$subtext1Alpha = b8c0e0

$subtext0 = rgb(a5adcb)
$subtext0Alpha = a5adcb

$overlay2 = rgb(939ab7)
$overlay2Alpha = 939ab7

$overlay1 = rgb(8087a2)
$overlay1Alpha = 8087a2

$overlay0 = rgb(6e738d)
$overlay0Alpha = 6e738d

$surface2 = rgb(5b6078)
$surface2Alpha = 5b6078

$surface1 = rgb(494d64)
$surface1Alpha = 494d64

$surface0 = rgb(363a4f)
$surface0Alpha = 363a4f

$base = rgb(24273a)
$baseAlpha = 24273a

$mantle = rgb(1e2030)
$mantleAlpha = 1e2030

$crust = rgb(181926)
$crustAlpha = 181926

input {
    kb_layout = us
    numlock_by_default = true
    kb_options = ctrl:nocaps
    resolve_binds_by_sym = true
}

device {
    name = at-translated-set-2-keyboard
    kb_variant = colemak_dh_ortho
    kb_layout = us
}
			'';
		# plugins = with pkgs.hyprlandPlugins; [
		# 	hypr-dynamic-cursors
		# ];
		# plugins = [
		 	# inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprfocus
		# ];
		settings = {
			env = [
				"ELECTRON_OZONE_PLATFORM_HINT,auto"
        			"NIXOS_OZONE_WL,1"
        			"SDL_VIDEODRIVER,wayland"
        			"_JAVA_AWT_WM_NONREPARENTING,1"
        			"CLUTTER_BACKEND,wayland"
        			"WLR_RENDERER,vulkan"
        			"XDG_CURRENT_DESKTOP,Hyprland"
        			"XDG_SESSION_DESKTOP,Hyprland"
        			"GDK_SCALE,1.5"
				"HYPRCURSOR_THEME,Catppuccin-Macchiato-Teal"
				"HYPRCURSOR_SIZE,24"
				"XCURSOR_THEME,Catppuccin-Macchiato-Teal"
				"XCURSOR_SIZE,24"
      			];
      			cursor = mkIf cfg.hyprland.nvidia {
        			no_hardware_cursors = true;
      			};
      			input = {
        			# kb_layout = "us";
        			# kb_variant = "colemak_dh_ortho";
           #
        			# numlock_by_default = true;
        			# kb_options = "ctrl:nocaps";
        			touchpad = {
          				disable_while_typing = true;
          				natural_scroll = false;
        			};
      			};
      			monitor =
        			map (
          				m:
          				let
            					resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
            					position = "${toString m.x}x${toString m.y}";
            					scale = "${toString m.scale}";
          				in
          				"${m.name},${if m.enabled then "${resolution},${position},${scale}" else "disable"}"
        			) config.monitors
        			++ [ ",preferred,auto,1" ];

      			gestures = {
      			};

      			misc = {
        			disable_splash_rendering = true;
        			disable_hyprland_logo = true;
        			mouse_move_enables_dpms = true;
        			# enable_swallow = true;
        			# swallow_regex = "^(kitty)$";
        			vfr = "on";
        			focus_on_activate = true;
      			};

      			windowrulev2 = [
        			# keep focus on albert
        			"stayfocused, class:(albert)"
        			"float, class:(albert)"
        			"center, class:(albert)"
      			];
    		};
  	};
}


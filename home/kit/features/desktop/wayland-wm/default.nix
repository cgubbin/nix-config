{
	config,
	lib,
	pkgs,
	...
}:
let
	inherit (lib) mkIf;
	cfg = config.home-config.desktop;
in
{
	imports = [
		./albert
		./hypridle.nix
		./hyprlock.nix
		./hyprpaper.nix
		./mako.nix
		./swaync.nix
		./waybar
	];

	home.packages = mkIf cfg.wayland.enable (
		with pkgs;
		[
			meson
			wayland-protocols
			wayland-utils
			wlroots
			copyq
			wl-clipboard
		]
	);

	services.playerctld.enable = cfg.wayland.enable;
}

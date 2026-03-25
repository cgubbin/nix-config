{ ... }:
{
    imports = [
        ./features
        ./global
    ];

    home-config = {
    	desktop = {
		stylix.enable = true;
		wayland = {
			enable = true;
			hyprland = {
				enable = true;
				nvidia = true;
			};
		};
	};
	custom-fonts = {
		dankMono.enable = true;
	};
        gaming.enable = true;
	gui = {
		kitty.enable = true;
		firefox = {
			enable = true;
		};
		utils.enable = true;
	};
	dev.devTools.enable = true;
	cli = {
		commonTools.enable = true;
		nvTop.enable = true;
	};
    };


    monitors = [
    	{
      		name = "eDP-1";
      		width = 3840;
      		height = 2400;
      		refreshRate = 60.0;
      		scale = 1.5;
      		x = 0;
      		workspace = "1";
      		primary = true;
    	}
    	{
      		name = "DP-5";
      		width = 2560;
      		height = 1440;
      		refreshRate = 59.95;
      		scale = 1.0;
      		x = 2560;
      		workspace = "2";
    	}
    	{
      		name = "DP-6";
      		width = 3840;
      		height = 2160;
      		refreshRate = 30.0;
      		scale = 1.5;
      		x = 5160;
      		workspace = "3";
    	}
    ];	
}

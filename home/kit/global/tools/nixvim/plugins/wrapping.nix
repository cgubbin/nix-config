{ ... }:
{
    programs.nixvim = {
        plugins.wrapping = {
		    enable = true;
        };
	};
}

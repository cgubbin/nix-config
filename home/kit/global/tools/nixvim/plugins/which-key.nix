{ ... }:
{
	programs.nixvim = {
        opts = {
            timeout = true;
        #     timeoutlen = 300;
        };
        plugins.which-key = {
		    enable = true;
            settings = { };
        };
	};
}

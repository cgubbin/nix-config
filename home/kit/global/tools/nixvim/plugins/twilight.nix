{ ... }:
{
	programs.nixvim = {
        plugins.twilight = {
		    enable = true;
		    settings = {
    			dimming.alpha = 0.4;
    			context = 20;
    			treesitter = true;
    			expand = [
      				"function"
      				"method"
    			];
  		    };
        };
	    plugins.web-devicons.enable = true;

        keymaps = [
            {
                mode = "n";
                key = "<leader>tt";
                action = "<cmd>Twilight<cr>";
                options.desc = "Toggle Twilight";
            }
        ];
	};

}

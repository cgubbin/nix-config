{ ... }:
{
	programs.nixvim = {
        plugins.todo-comments = {
		    enable = true;
            settings = {
                keywords = {
                    TODO = { icon = ""; color = "info"; };
                    FIX = { icon = ""; color = "error"; };
                    NOTE = { icon = ""; color = "hint"; };
                    WARN = { icon = ""; color = "warning"; };
                };
            };
        };

        keymaps = [
            {
                mode = "n";
                key = "<leader>ft";
                action = "<cmd>TodoTelescope<cr>";
                options.desc = "Find TODOs";
            }
            {
                mode = "n";
                key = "<leader>xt";
                action = "<cmd>TodoTrouble<cr>";
                options.desc = "TODOs (Trouble)";
            }
        ];
	};
}

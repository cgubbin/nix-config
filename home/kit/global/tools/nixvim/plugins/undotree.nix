{ ... }:
{
	programs.nixvim = {
        plugins.undotree = {
		    enable = true;
            settings = {
                WindowLayout = 2;
            };
        };

        keymaps = [
            {
                mode = "n";
                key = "<leader>ut";
                action = "<cmd>UndotreeToggle<cr>";
                options.desc = "Toggle Undotree";
            }
        ];
	};
}

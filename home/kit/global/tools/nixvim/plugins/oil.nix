{
	programs.nixvim.plugins.oil = {
		enable = true;
		settings = {
			view_options.show_hidden = true;
			skip_confirm_for_simple_edits = true;
			win_options = {
      				wrap = false;
      				signcolumn = "no";
      				cursorcolumn = false;
      				foldcolumn = "0";
      				spell = false;
      				list = false;
      				conceallevel = 3;
      				concealcursor = "ncv";
    			};
			keymaps = {
                "<CR>" = "actions.select";
                "<C-s>" = { 
                    action = "actions.select"; 
                    opts = { vertical = true; }; 
                };
                "<C-h>" = { 
                    action = "actions.select"; 
                    opts = { horizontal = true; }; 
                };
                "<C-t>" = { 
                    action = "actions.select"; 
                    opts = { tab = true; }; 
                };
				"y." = "actions.copy_entry_path";
                "g?" = "actions.show_help";
                "<C-p>" = "actions.preview";
                "<C-c>" = "actions.close";
                "<C-l>" = "actions.refresh";
                "-" = "actions.parent";
                "_" = "actions.open_cwd";
                "`" = "actions.cd";
                "gx" = "actions.open_external";
			};
		};
	};
}

{
  lib,
  config,
  ...
}:
{
  programs.nixvim = {
    globals = {
      mapleader = "\\";
      maplocalleader = "``";
    };

    keymaps = [
    	{
		action = ":close<CR>";
		key = "<C-x>";
		mode = ["n"];
		options = {
			desc = "Close";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = ":resize -2<CR>";
		key = "<C-Up>";
		mode = ["n"];
		options = {
			desc = "Shortern";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = ":resize +2<CR>";
		key = "<C-Down>";
		mode = ["n"];
		options = {
			desc = "Heighten";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = ":vertical resize +2<CR>";
		key = "<C-Left>";
		mode = ["n"];
		options = {
			desc = "Widen";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = ":resize -2<CR>";
		key = "<C-Right>";
		mode = ["n"];
		options = {
			desc = "Narrow";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = ":bprevious<CR>";
		key = "[b";
		mode = ["n"];
		options = {
			desc = "Previous buffer";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = ":bnext<CR>";
		key = "]b";
		mode = ["n"];
		options = {
			desc = "Next buffer";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = ":blast<CR>";
		key = "]B";
		mode = ["n"];
		options = {
			desc = "Last buffer";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = ":bfirst<CR>";
		key = "[B";
		mode = ["n"];
		options = {
			desc = "First buffer";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = "nzzzv";
		key = "n";
		mode = ["n"];
		options = {
			desc = "Centered forward search";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = "Nzzzv";
		key = "N";
		mode = ["n"];
		options = {
			desc = "Centered backward search";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = "<C-d>zz";
		key = "<C-d>";
		mode = ["n"];
		options = {
			desc = "Centered downward scroll";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = "<C-u>zz";
		key = "<C-u>";
		mode = ["n"];
		options = {
			desc = "Centered upward scroll";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = "mzJ`z";
		key = "J";
		mode = ["n"];
		options = {
			desc = "Delete blank lines below, maintaining cursor position";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = "vim.lsp.buf.format";
		key = "<leader>f";
		mode = ["n"];
		options = {
			desc = "Format code";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = "+y";
		key = "<leader>y";
		mode = [
			"n"
			"v"
		];
		options = {
			desc = "Yank into buffer";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = "+Y";
		key = "<leader>Y";
		mode = [
			"n"
			"v"
		];
		options = {
			desc = "Yank into buffer";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = "_d";
		key = "<leader>d";
		mode = [
			"n"
			"v"
		];
		options = {
			desc = "Yank into black hole register";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = ":move-2<CR>";
		key = "<M-k>";
		mode = ["n"];
		options = {
			desc = "Move current line down";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = ":move+2<CR>";
		key = "<M-j>";
		mode = ["n"];
		options = {
			desc = "Move current line up";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = "<Esc>";
		key = "<C-c>";
		mode = ["i"];
		options = {
			desc = "Escape to file selection";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = ">gv";
		key = ">";
		mode = ["v"];
		options = {
			desc = "Better indenting";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = "<gv";
		key = "<";
		mode = ["v"];
		options = {
			desc = "Better indenting";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = ">gv";
		key = "<TAB>";
		mode = ["v"];
		options = {
			desc = "Better indenting";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = "<gv";
		key = "<S-TAB>";
		mode = ["v"];
		options = {
			desc = "Better indenting";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = ":m '<-2<CR>gv=gv";
		key = "K";
		mode = [
			"v"
			"x"
		];
		options = {
			desc = "Better indenting";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = ":m '>+1<CR>gv=gv";
		key = "J";
		mode = [
			"v"
			"x"
		];
		options = {
			desc = "Better indenting";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = ":m '<-2<CR>gv=gv";
		key = "<A-k>";
		mode = ["x"];
		options = {
			desc = "Better indenting";
			silent = true;
			noremap = true;
		};
	}
    	{
		action = ":m '>+1<CR>gv=gv";
		key = "<A-j>";
		mode = ["x"];
		options = {
			desc = "Better indenting";
			silent = true;
			noremap = true;
		};
	}
        {
        action = "<cmd>Oil<CR>";
        key = "-";
        mode = "n";
        options = {
            desc = "Toggle Oil.";
            silent = true;
            noremap = true;
        };
    }
        {
        action = "<cmd>Neotree toggle<CR>";
        key = "<C-b>";
        mode = "n";
        options = {
            desc = "Toggle Tree View.";
            silent = true;
            noremap = true;
        };
    }
    ];
  };
}

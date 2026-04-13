{
  lib,
  config,
  ...
}: {
  programs.nixvim = {
    extraFiles = {
      # Lua config
      "lua/kit/functions/utils.lua".source = ./lua/kit/functions/utils.lua;
      "lua/kit/functions/init.lua".source = ./lua/kit/functions/init.lua;
      "lua/kit/functions/patents.lua".source = ./lua/kit/functions/patents.lua;
      "lua/kit/functions/patent_triage.lua".source = ./lua/kit/functions/patent_triage.lua;
      # Treesitter queries
      "after/queries/ecma/textobjects.scm".source = ./after/queries/ecma/textobjects.scm;

      # Markdown snippets
      "LuaSnip/markdown/utils/conditions.lua".source = ./snippets/markdown/utils/conditions.lua;
      "LuaSnip/markdown/chem.lua".source = ./snippets/markdown/chem.lua;
      "LuaSnip/markdown/math.lua".source = ./snippets/markdown/math.lua;
      "LuaSnip/markdown/math_commands.lua".source = ./snippets/markdown/math_commands.lua;

      # Tex snippets
      "LuaSnip/tex/utils/conditions.lua".source = ./snippets/tex/utils/conditions.lua;
      "LuaSnip/tex/utils/helpers.lua".source = ./snippets/tex/utils/helpers.lua;
      "LuaSnip/tex/utils/init.lua".source = ./snippets/tex/utils/init.lua;
      "LuaSnip/tex/utils/scaffolding.lua".source = ./snippets/tex/utils/scaffolding.lua;
      "LuaSnip/tex/chem.lua".source = ./snippets/tex/chem.lua;
      "LuaSnip/tex/commands.lua".source = ./snippets/tex/commands.lua;
      "LuaSnip/tex/delimiters.lua".source = ./snippets/tex/delimiters.lua;
      "LuaSnip/tex/environments.lua".source = ./snippets/tex/environments.lua;
      "LuaSnip/tex/math.lua".source = ./snippets/tex/math.lua;
      "LuaSnip/tex/math_commands.lua".source = ./snippets/tex/math_commands.lua;
    };
    opts = {
      backup = false;
      clipboard = "unnamedplus"; # allows neovim to access the system clipboard
      cmdheight = 2; # more space in the neovim command line for displaying messages
      # completeopt = { "menuone", "noselect" }, # mostly just for cmp
      conceallevel = 0; # so that `` is visible in markdown files
      fileencoding = "utf-8"; # the encoding written to a file
      hlsearch = true; # highlight all matches on previous search pattern
      ignorecase = true; # ignore case in search patterns
      mouse = "a"; # allow the mouse to be used in neovim
      pumheight = 10; # pop up menu height
      showmode = false; # we don't need to see things like -- INSERT -- anymore
      showtabline = 2; # always show tabs
      smartcase = true; # smart case
      smartindent = true; # make indenting smarter again
      splitbelow = true; # force all horizontal splits to go below current window
      splitright = true; # force all vertical splits to go to the right of current window
      swapfile = false; # creates a swapfile
      termguicolors = true; # set term gui colors (most terminals support this)
      timeoutlen = 1000; # time to wait for a mapped sequence to complete (in milliseconds)
      undofile = true; # enable persistent undo
      updatetime = 50; # faster completion (4000ms default)
      writebackup = false; # if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
      expandtab = true; # convert tabs to spaces
      shiftwidth = 4; # the number of spaces inserted for each indentation
      softtabstop = 4; # insert 2 spaces for a tab
      tabstop = 4; # insert 2 spaces for a tab
      cursorline = true; # highlight the current line
      number = true; # set numbered lines
      relativenumber = true; # set relative numbered lines
      numberwidth = 4; # set number column width to 2 {default 4}
      signcolumn = "yes"; # always show the sign column, otherwise it would shift the text each time
      wrap = false; # display lines as one long line
      scrolloff = 8; # is one of my fav
      sidescrolloff = 8;
      colorcolumn = "80";
      guicursor = "";
      incsearch = true;
      nu = true;
      undodir = ["${config.xdg.dataHome}/nvim/undo"];
      # undodir = os.getenv("HOME") .. "/.vim/undodir",
    };
  };
}

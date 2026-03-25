{ ... }:
{
  programs.nixvim.plugins.alpha = {
    enable = true;

    settings.layout = [
      { type = "padding"; val = 4; }

      {
        type = "text";
        val = [
          "  n i x v i m"
          ""
          "  notes  ·  notebooks  ·  code"
        ];
        opts = {
          position = "center";
          hl = "Comment";
        };
      }

      { type = "padding"; val = 2; }

      {
        type = "group";
        val = [
          {
            type = "button";
            val = "󰎔  Today";
            on_press.__raw = ''
              function() vim.cmd("ObsidianToday") end
            '';
            opts = { shortcut = "t"; position = "center"; width = 32; };
          }

          {
            type = "button";
            val = "󰈞  Notes";
            on_press.__raw = ''
              function() vim.cmd("ObsidianQuickSwitch") end
            '';
            opts = { shortcut = "o"; position = "center"; width = 32; };
          }

          {
            type = "button";
            val = "󱚌  New note";
            on_press.__raw = ''
              function() vim.cmd("ObsidianNew") end
            '';
            opts = { shortcut = "n"; position = "center"; width = 32; };
          }

          {
            type = "button";
            val = "󱓞  Notebook";
            on_press.__raw = ''
              function()
                vim.api.nvim_feedkeys(":NewNotebook ", "n", false)
              end
            '';
            opts = { shortcut = "b"; position = "center"; width = 32; };
          }

          {
            type = "button";
            val = "󰱼  Files";
            on_press.__raw = ''
              function() require("telescope.builtin").find_files() end
            '';
            opts = { shortcut = "f"; position = "center"; width = 32; };
          }

          {
            type = "button";
            val = "  Recent";
            on_press.__raw = ''
              function() require("telescope.builtin").oldfiles() end
            '';
            opts = { shortcut = "r"; position = "center"; width = 32; };
          }

          {
            type = "button";
            val = "󰒲  Git";
            on_press.__raw = ''
              function() vim.cmd("LazyGit") end
            '';
            opts = { shortcut = "g"; position = "center"; width = 32; };
          }

          {
            type = "button";
            val = "󰩈  Quit";
            on_press.__raw = ''
              function() vim.cmd("qa") end
            '';
            opts = { shortcut = "q"; position = "center"; width = 32; };
          }
        ];
        opts = { spacing = 1; };
      }

      { type = "padding"; val = 2; }

      {
        type = "text";
        val = "obsidian  ·  quarto  ·  molten";
        opts = {
          position = "center";
          hl = "Comment";
        };
      }
    ];
  };
}

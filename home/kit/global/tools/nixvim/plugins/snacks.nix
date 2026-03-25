{ config, pkgs, ... }:

let
  helpers = config.lib.nixvim;
in
{
  programs.nixvim = {
    plugins.snacks = {
      enable = true;

      settings = {
        bigfile.enabled = true;
        dashboard.enabled = false;

        # Keep this only if you're on kitty / wezterm / ghostty
        image.enabled = false;

        notifier = {
          enabled = true;
          timeout = 3000;
        };

        quickfile.enabled = true;
        statuscolumn.enabled = true;
        words.enabled = true;

        styles.notification.wo.wrap = true;
      };

      luaConfig.post = ''
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end

        _G.bt = function()
          Snacks.debug.backtrace()
        end

        vim.print = _G.dd

        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle.option(
          "conceallevel",
          { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }
        ):map("<leader>uc")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.option(
          "background",
          { off = "light", on = "dark", name = "Dark Background" }
        ):map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
      '';
    };

    extraPackages = with pkgs; [
      lazygit
    ];

    keymaps = [
      {
        mode = "n";
        key = "<leader>.";
        action = helpers.mkRaw ''function() Snacks.scratch() end'';
        options.desc = "Toggle Scratch Buffer";
      }
      {
        mode = "n";
        key = "<leader>S";
        action = helpers.mkRaw ''function() Snacks.scratch.select() end'';
        options.desc = "Select Scratch Buffer";
      }
      {
        mode = "n";
        key = "<leader>n";
        action = helpers.mkRaw ''function() Snacks.notifier.show_history() end'';
        options.desc = "Notification History";
      }
      {
        mode = "n";
        key = "<leader>bd";
        action = helpers.mkRaw ''function() Snacks.bufdelete() end'';
        options.desc = "Delete Buffer";
      }
      {
        mode = "n";
        key = "<leader>cR";
        action = helpers.mkRaw ''function() Snacks.rename.rename_file() end'';
        options.desc = "Rename File";
      }
      {
        mode = "n";
        key = "<leader>gB";
        action = helpers.mkRaw ''function() Snacks.gitbrowse() end'';
        options.desc = "Git Browse";
      }
      {
        mode = "n";
        key = "<leader>gb";
        action = helpers.mkRaw ''function() Snacks.git.blame_line() end'';
        options.desc = "Git Blame Line";
      }
      {
        mode = "n";
        key = "<leader>gf";
        action = helpers.mkRaw ''function() Snacks.lazygit.log_file() end'';
        options.desc = "Lazygit Current File History";
      }
      {
        mode = "n";
        key = "<leader>gg";
        action = helpers.mkRaw ''function() Snacks.lazygit() end'';
        options.desc = "Lazygit";
      }
      {
        mode = "n";
        key = "<leader>gl";
        action = helpers.mkRaw ''function() Snacks.lazygit.log() end'';
        options.desc = "Lazygit Log (cwd)";
      }
      {
        mode = "n";
        key = "<leader>un";
        action = helpers.mkRaw ''function() Snacks.notifier.hide() end'';
        options.desc = "Dismiss All Notifications";
      }
      {
        mode = "n";
        key = "<C-/>";
        action = helpers.mkRaw ''function() Snacks.terminal() end'';
        options.desc = "Toggle Terminal";
      }
      {
        mode = "n";
        key = "<C-_>";
        action = helpers.mkRaw ''function() Snacks.terminal() end'';
        options.desc = "which_key_ignore";
      }
      {
        mode = [ "n" "t" ];
        key = "]]";
        action = helpers.mkRaw ''function() Snacks.words.jump(vim.v.count1) end'';
        options.desc = "Next Reference";
      }
      {
        mode = [ "n" "t" ];
        key = "[[";
        action = helpers.mkRaw ''function() Snacks.words.jump(-vim.v.count1) end'';
        options.desc = "Prev Reference";
      }
      {
        mode = "n";
        key = "<leader>N";
        action = helpers.mkRaw ''
          function()
            Snacks.win({
              file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
              width = 0.6,
              height = 0.6,
              wo = {
                spell = false,
                wrap = false,
                signcolumn = "yes",
                statuscolumn = " ",
                conceallevel = 3,
              },
            })
          end
        '';
        options.desc = "Neovim News";
      }
    ];
  };
}

{
  config,
  pkgs,
  ...
}: let
  helpers = config.lib.nixvim;
in {
  programs.nixvim = {
    plugins.neotest = {
      enable = true;
      autoLoad = true;
    };

    extraConfigLua = ''
      local neotest_rust_setup_done = false

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "rust",
        callback = function()
          if neotest_rust_setup_done then
            return
          end
          neotest_rust_setup_done = true

          require("neotest").setup({
            adapters = {
              require("rustaceanvim.neotest"),
            },
            quickfix = {
              enabled = false,
            },
            output = {
              enabled = true,
              open_on_run = false,
            },
            output_panel = {
              enabled = true,
              open = "botright split | resize 12",
            },
            summary = {
              enabled = true,
              animated = false,
              follow = true,
            },
            status = {
              enabled = true,
              virtual_text = true,
            },
          })
        end,
      })
    '';

    keymaps = [
      {
        mode = "n";
        key = "<leader>tn";
        action = helpers.mkRaw ''function() require("neotest").run.run() end'';
        options.desc = "Run nearest test";
      }
      {
        mode = "n";
        key = "<leader>tf";
        action = helpers.mkRaw ''function() require("neotest").run.run(vim.fn.expand("%")) end'';
        options.desc = "Run file tests";
      }
      {
        mode = "n";
        key = "<leader>ts";
        action = helpers.mkRaw ''function() require("neotest").summary.toggle() end'';
        options.desc = "Toggle test summary";
      }
      {
        mode = "n";
        key = "<leader>to";
        action = helpers.mkRaw ''function() require("neotest").output.open({ enter = true }) end'';
        options.desc = "Open test output";
      }
    ];
  };
}

_: {
  flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-neotest" =
    {
      config,
      pkgs,
      ...
    }:
    let
      helpers = config.lib.nixvim;
    in
    {
      programs.nixvim = {
        plugins.neotest = {
          enable = true;
          autoLoad = true;
        };

        extraPlugins = [
          pkgs.vimPlugins.neotest-python
          (pkgs.vimPlugins.neotest-rust.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [
              ../../../../../assets/editor/patches/neotest-rust-project-env.patch
            ];
          }))
        ];

        extraConfigLua = ''
          local project = require("kit.project")
          local adapters = {}

          local ok_python, neotest_python = pcall(require, "neotest-python")
          if ok_python then
            table.insert(adapters, project.wrap_adapter(neotest_python({
              runner = "pytest",
              python = project.python,
              pytest_discover_instances = false,
              dap = { justMyCode = false },
            })))
          end

          local ok_rust, neotest_rust = pcall(require, "neotest-rust")
          if ok_rust then
            table.insert(adapters, project.wrap_adapter(neotest_rust({
              args = { "--no-capture" },
              dap_adapter = "lldb",
            })))
          end

          require("neotest").setup({
            adapters = adapters,
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
            icons = {
              child_indent = "│",
              child_prefix = "├",
              collapsed = "─",
              expanded = "╮",
              failed = "✖",
              final_child_indent = " ",
              final_child_prefix = "╰",
              non_collapsible = "─",
              passed = "✔",
              running = "⟳",
              skipped = "○",
              unknown = "?",
            },
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
            key = "<leader>tw";
            action = helpers.mkRaw ''function() require("neotest").watch.toggle() end'';
            options.desc = "Toggle watch nearest test";
          }
          {
            mode = "n";
            key = "]t";
            action = helpers.mkRaw ''function() require("neotest").jump.next({ status = "failed" }) end'';
            options.desc = "Next failed test";
          }
          {
            mode = "n";
            key = "[t";
            action = helpers.mkRaw ''function() require("neotest").jump.prev({ status = "failed" }) end'';
            options.desc = "Previous failed test";
          }
          {
            mode = "n";
            key = "<leader>td";
            action = helpers.mkRaw ''function() require("neotest").run.run({ strategy = "dap" }) end'';
            options.desc = "Debug nearest test";
          }
          {
            mode = "n";
            key = "<leader>tf";
            action = helpers.mkRaw ''function() require("neotest").run.run(vim.fn.expand("%:p")) end'';
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
          {
            mode = "n";
            key = "<leader>tO";
            action = helpers.mkRaw ''function() require("neotest").output_panel.toggle() end'';
            options.desc = "Toggle test output panel";
          }
          {
            mode = "n";
            key = "<leader>tr";
            action = helpers.mkRaw ''function() require("neotest").run.run_last() end'';
            options.desc = "Re-run last test";
          }
          {
            mode = "n";
            key = "<leader>tx";
            action = helpers.mkRaw ''function() require("neotest").run.stop() end'';
            options.desc = "Stop test";
          }
        ];
      };
    };
}

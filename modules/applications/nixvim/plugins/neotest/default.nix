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

        extraPlugins = with pkgs.vimPlugins; [
          neotest-python
          neotest-rust
        ];

        extraConfigLua = ''
          local function project_root(markers)
            local path = vim.fn.expand("%:p:h")
            if path == "" then
              path = vim.loop.cwd()
            end

            local found = vim.fs.find(markers, {
              upward = true,
              path = path,
            })[1]

            if found then
              return vim.fs.dirname(found)
            end

            return vim.loop.cwd()
          end

          local function python_root()
            return project_root({ "pyproject.toml", ".git", "flake.nix" })
          end

          local function rust_root()
            return project_root({ "Cargo.toml", ".git", "flake.nix" })
          end

          local function load_direnv(root)
            if not root or root == "" then
              return
            end

            if vim.fn.executable("direnv") ~= 1 then
              return
            end

            local result = vim.system(
              { "direnv", "export", "json" },
              { text = true, cwd = root }
            ):wait()

            if result.code ~= 0 or not result.stdout or result.stdout == "" then
              return
            end

            local ok, env = pcall(vim.json.decode, result.stdout)
            if not ok or type(env) ~= "table" then
              return
            end

            for k, v in pairs(env) do
              if type(v) == "string" then
                vim.env[k] = v
              end
            end
          end

          -- Import project env whenever entering relevant buffers
          vim.api.nvim_create_autocmd("FileType", {
            pattern = { "python", "rust" },
            callback = function(args)
              local ft = vim.bo[args.buf].filetype
              if ft == "python" then
                load_direnv(python_root())
              elseif ft == "rust" then
                load_direnv(rust_root())
              end
            end,
          })

          local adapters = {}

          local ok_python, neotest_python = pcall(require, "neotest-python")
          if ok_python then
            table.insert(adapters, neotest_python({
              runner = "pytest",
              python = function()
                local root = python_root()
                local venv_python = root .. "/.venv/bin/python"
                if vim.fn.executable(venv_python) == 1 then
                  return venv_python
                end
                return "python3"
              end,
              pytest_discover_instances = true,
            }))
          end

          local ok_rust, neotest_rust = pcall(require, "neotest-rust")
          if ok_rust then
            table.insert(adapters, neotest_rust({
              args = { "--no-capture" },
            }))
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

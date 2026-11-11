{ config, ... }:
let
  top = config;
in
{
  flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-overseer" =
    {
      config,
      lib,
      ...
    }:
    let
      helpers = config.lib.nixvim;
    in
    {
      imports = [
        top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-overseer-python"
        top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-overseer-rust"
      ];
      programs.nixvim = {
        plugins.overseer = {
          enable = true;

          settings = {
            dap = false;
            disable_template_modules = [
              "^overseer%.template%.just$"
              "^overseer%.template%.cargo$"
            ];

            task_list = {
              direction = "right";
              min_width = 40;
              max_width = 80;
            };

            form = {
              border = "rounded";
            };

            task_win = {
              border = "rounded";
            };
          };
        };

        keymaps = [
          {
            mode = "n";
            key = "<leader>Or";
            action = "<cmd>OverseerRun<CR>";
            options.desc = "Run task";
          }
          {
            mode = "n";
            key = "<leader>Oo";
            action = "<cmd>OverseerToggle<CR>";
            options.desc = "Toggle task list";
          }
          {
            mode = "n";
            key = "<leader>Oa";
            action = "<cmd>OverseerQuickAction<CR>";
            options.desc = "Task action";
          }

          {
            mode = "n";
            key = "<leader>Ol";
            action = helpers.mkRaw ''
              function()
                local tasks = require("overseer").list_tasks()
                if not tasks[1] then
                  vim.notify("No task to restart", vim.log.levels.INFO)
                  return
                end
                require("overseer").run_action(tasks[1], "restart")
              end
            '';
            options.desc = "Restart first task";
          }
          {
            mode = "n";
            key = "<leader>Oi";
            action = "<cmd>OverseerInfo<cr>";
            options.desc = "Overseer info";
          }
        ];

        plugins.which-key.settings.spec = [
          {
            __unkeyed-1 = "<leader>O";
            group = "Tasks";
          }
        ];

        extraConfigLua = lib.mkBefore ''
          local function overseer_project_root(markers)
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

          _G.overseer_project_root = overseer_project_root
        '';
      };
    }
  #     extraConfigLua = ''
  #       local overseer = require("overseer")
  #       overseer.setup({
  #         strategy = "toggleterm",
  #         -- Disable built-in Just template provider
  #         disable_template_modules = { "^overseer%.template%.just$" },
  #       })
  #       --------------------------------------------------
  #       -- Helpers
  #       --------------------------------------------------
  #       local function project_root()
  #         local markers = { "pyproject.toml", ".git", "flake.nix" }
  #         local path = vim.fn.expand("%:p:h")
  #         if path == "" then
  #           path = vim.loop.cwd()
  #         end
  #         local found = vim.fs.find(markers, {
  #           upward = true,
  #           path = path,
  #         })[1]
  #         if found then
  #           return vim.fs.dirname(found)
  #         end
  #         return vim.loop.cwd()
  #       end
  #       local function current_file()
  #         local file = vim.fn.expand("%:p")
  #         if file == "" then
  #           return nil
  #         end
  #         return file
  #       end
  #       local function is_python_project()
  #         return vim.fn.filereadable(project_root() .. "/pyproject.toml") == 1
  #       end
  #       local function is_python_file()
  #         local file = current_file()
  #         return file ~= nil and file:match("%.py$") ~= nil
  #       end
  #       local function is_test_file()
  #         local file = current_file()
  #         if not file then
  #           return false
  #         end
  #         return file:match("/tests/")
  #           or file:match("/test_.*%.py$")
  #           or file:match(".*_test%.py$")
  #       end
  #       --------------------------------------------------
  #       -- Template helper
  #       --------------------------------------------------
  #       local function register_just(name, target, tags)
  #         overseer.register_template({
  #           name = name,
  #           tags = tags or { "python" },
  #           priority = 60,
  #           condition = {
  #             callback = function()
  #               return is_python_project()
  #             end,
  #           },
  #           builder = function()
  #             local root = project_root()
  #             return {
  #               cmd = { "direnv", "exec", root, "just", target },
  #               cwd = root,
  #             }
  #           end,
  #         })
  #       end
  #       --------------------------------------------------
  #       -- Core tasks (just-based)
  #       --------------------------------------------------
  #       register_just("Run: App", "run", { "run" })
  #       register_just("Test: All", "test", { "test" })
  #       register_just("Lint: Ruff Check", "lint", { "lint" })
  #       register_just("Format: Ruff", "fmt", { "format" })
  #       register_just("Typecheck: Pyright", "typecheck", { "typecheck" })
  #       register_just("Deps: UV Sync", "sync", { "deps" })
  #       register_just("Test: Coverage", "coverage", { "test" })
  #       register_just("Nix: Flake Check", "flake-check", { "nix" })
  #       --------------------------------------------------
  #       -- File-based tasks
  #       --------------------------------------------------
  #       overseer.register_template({
  #         name = "Run: File",
  #         tags = { "run" },
  #         priority = 55,
  #         condition = {
  #           callback = function()
  #             return is_python_project() and is_python_file()
  #           end,
  #         },
  #         builder = function()
  #           local root = project_root()
  #           return {
  #             cmd = { "direnv", "exec", root, "uv", "run", "python", current_file() },
  #             cwd = root,
  #           }
  #         end,
  #       })
  #       overseer.register_template({
  #         name = "Test: File",
  #         tags = { "test" },
  #         priority = 55,
  #         condition = {
  #           callback = function()
  #             return is_python_project() and is_test_file()
  #           end,
  #         },
  #         builder = function()
  #           local root = project_root()
  #           return {
  #             cmd = { "direnv", "exec", root, "just", "test-file", current_file() },
  #             cwd = root,
  #           }
  #         end,
  #       })
  #     '';
  #   };
  # };
  ;
}

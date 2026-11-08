_: {
  flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-overseer-python" = { lib, ... }: {
    programs.nixvim.extraConfigLua = lib.mkAfter ''
      local overseer = require("overseer")

      local function project_root()
        return _G.overseer_project_root({ "pyproject.toml", ".git", "flake.nix" })
      end

      local function current_file()
        local file = vim.fn.expand("%:p")
        if file == "" then
          return nil
        end
        return file
      end

      local function is_python_project()
        return vim.fn.filereadable(project_root() .. "/pyproject.toml") == 1
      end

      local function is_python_file()
        local file = current_file()
        return file ~= nil and file:match("%.py$") ~= nil
      end

      local function is_test_file()
        local file = current_file()
        if not file then
          return false
        end
        return file:match("/tests/")
          or file:match("/test_.*%.py$")
          or file:match(".*_test%.py$")
      end

      local function register_just(name, target, tags)
        overseer.register_template({
          name = name,
          tags = tags or { "python" },
          priority = 60,
          condition = {
            callback = function()
              return is_python_project()
            end,
          },
          builder = function()
            local root = project_root()
            return {
              cmd = { "direnv", "exec", root, "just", target },
              cwd = root,
            }
          end,
        })
      end

      register_just("Python: Run App", "run", { "python", "run" })
      register_just("Python: Test All", "test", { "python", "test" })
      register_just("Python: Lint", "lint", { "python", "lint" })
      register_just("Python: Format", "fmt", { "python", "format" })
      register_just("Python: Typecheck", "typecheck", { "python", "typecheck" })
      register_just("Python: Sync", "sync", { "python", "deps" })
      register_just("Python: Coverage", "coverage", { "python", "coverage" })
      register_just("Python: Flake Check", "flake-check", { "python", "nix" })

      overseer.register_template({
        name = "Python: Run File",
        tags = { "python", "run" },
        priority = 55,
        condition = {
          callback = function()
            return is_python_project() and is_python_file()
          end,
        },
        builder = function()
          local root = project_root()
          return {
            cmd = { "direnv", "exec", root, "uv", "run", "python", current_file() },
            cwd = root,
          }
        end,
      })

      overseer.register_template({
        name = "Python: Test File",
        tags = { "python", "test" },
        priority = 55,
        condition = {
          callback = function()
            return is_python_project() and is_test_file()
          end,
        },
        builder = function()
          local root = project_root()
          return {
            cmd = { "direnv", "exec", root, "just", "test-file", current_file() },
            cwd = root,
          }
        end,
      })
    '';
  };
}

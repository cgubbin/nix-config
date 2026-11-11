local M = {}
local envs = require("kit.project_env")
local python = require("kit.python")
local markers = { "pyproject.toml", "pixi.toml", "Cargo.toml", ".git", "flake.nix", ".envrc" }

function M.root(path)
  path = path and path ~= "" and path or vim.api.nvim_buf_get_name(0)
  local stat = path ~= "" and (vim.uv or vim.loop).fs_stat(path) or nil
  local start = stat and stat.type == "directory" and path or vim.fs.dirname(path)
  local found = vim.fs.find(markers, { upward = true, path = start or vim.fn.getcwd() })[1]
  return found and vim.fs.dirname(found) or vim.fn.getcwd()
end

function M.command(root, command)
  if vim.fn.executable("direnv") ~= 1 then
    error("direnv is unavailable; install it to run a project command")
  end
  return vim.list_extend({ "direnv", "exec", root }, command)
end

function M.await_env(root)
  local future = require("nio").control.future()
  envs.load(root, function(value, err) future.set({ value = value, err = err }) end)
  local result = future.wait()
  if not result.value then error(result.err or "project environment unavailable") end
  return result.value
end

function M.python(root)
  local path, err = python.resolve(root, M.await_env(root))
  if not path then error(err) end
  return path
end

function M.wrap_adapter(adapter)
  local original = adapter.build_spec
  adapter.build_spec = function(args)
    local position = args.tree:data()
    local root = adapter.root(position.path) or M.root(position.path)
    local spec = original(args)
    if not spec then return spec end
    if args.strategy ~= "dap" then
      local command = type(spec.command) == "string" and { "sh", "-c", spec.command } or spec.command
      spec.command = M.command(root, command)
    elseif type(spec.strategy) == "table" then
      spec.strategy.cwd = root
      if spec.strategy.type == "python" then spec.strategy.console = "internalConsole" end
    end
    spec.cwd = root
    return spec
  end
  return adapter
end

function M.setup_lsp()
  local start = vim.lsp.start
  vim.lsp.start = function(config, opts)
    if type(config.cmd) == "table" and config.cmd[1] ~= "direnv" then
      local root = type(config.root_dir) == "string" and config.root_dir or M.root()
      if vim.fn.executable("direnv") == 1 then
        config = vim.deepcopy(config)
        config.cmd = M.command(root, config.cmd)
      else
        vim.notify("direnv is unavailable; LSP started without a project environment", vim.log.levels.WARN)
      end
    end
    return start(config, opts)
  end
end

function M.setup()
  M.setup_lsp()
  vim.api.nvim_create_user_command("ProjectEnvRefresh", function()
    envs.invalidate(M.root())
    vim.notify("Project environment cleared; restart existing language servers to reload it")
  end, {})
end

return M

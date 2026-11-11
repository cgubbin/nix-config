local M = {}
local envs = require("kit.project_env")
local python = require("kit.python")
local python_env = require("kit.python_env")
local markers = { "pyproject.toml", "pixi.toml", "Cargo.toml", ".git", "flake.nix", ".envrc" }

function M.root(path)
  path = path and path ~= "" and path or vim.api.nvim_buf_get_name(0)
  local stat = path ~= "" and (vim.uv or vim.loop).fs_stat(path) or nil
  local start = stat and stat.type == "directory" and path or vim.fs.dirname(path)
  local found = vim.fs.find(markers, { upward = true, path = start or vim.fn.getcwd() })[1]
  return found and vim.fs.dirname(found) or vim.fn.getcwd()
end

function M.command(root, command, role)
  if vim.fn.executable("direnv") ~= 1 then
    error("direnv is unavailable; install it to run a project command")
  end
  local choice = role == "ruff" and python_env.get_tool(root) or python_env.get(root)
  if choice then
    local required = role == "ruff" and "ruff" or "python"
    if not (vim.uv or vim.loop).fs_access(choice.path .. "/bin/" .. required, "X") then
      error("Selected " .. (role or "Python") .. " environment is missing " .. required .. ": " .. choice.label)
    end
    if choice.kind == "pixi" then
      command = vim.list_extend({ "pixi", "run", "--frozen", "--no-install", "--offline", "--manifest-path", root, "--environment", choice.name }, command)
    else
      command = vim.list_extend({ "sh", "-c", 'export VIRTUAL_ENV="$1"; export PATH="$1/bin:$PATH"; shift; exec "$@"', "project-env", choice.path }, command)
    end
  end
  return vim.list_extend({ "direnv", "exec", root }, command)
end

function M.load_env(root, callback)
  envs.load(root, function(env, err)
    if not env then return callback(nil, err) end
    python_env.apply(root, env, callback)
  end)
end

function M.python_tool(root, name)
  local choice = name == "ruff" and python_env.get_tool(root) or python_env.get(root)
  if not choice and name == "ruff" and (vim.uv or vim.loop).fs_stat(root .. "/pyproject.toml") then
    local local_tool = root .. "/.venv/bin/ruff"
    if (vim.uv or vim.loop).fs_access(local_tool, "X") then return local_tool end
    error("Ruff is unavailable in the project .venv; use :ProjectRuffSelect after preparing a lint environment")
  end
  if not choice then return name end
  local tool = choice.path .. "/bin/" .. name
  if not (vim.uv or vim.loop).fs_access(tool, "X") then
    error(name .. " is unavailable in selected Python environment " .. choice.label)
  end
  return tool
end

function M.await_env(root)
  local future = require("nio").control.future()
  M.load_env(root, function(value, err) future.set({ value = value, err = err }) end)
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
        local choice = python_env.get(root)
        if config.name == "ruff" then
          local ok, tool = pcall(M.python_tool, root, "ruff")
          if not ok then vim.notify(tool, vim.log.levels.WARN); return nil end
          config.cmd[1] = tool
        end
        if choice and config.name == "pyright" then
          local local_pyright = choice.path .. "/bin/pyright-langserver"
          if (vim.uv or vim.loop).fs_access(local_pyright, "X") then config.cmd[1] = local_pyright end
          config.settings = vim.tbl_deep_extend("force", config.settings or {}, { python = { pythonPath = choice.path .. "/bin/python" } })
        end
        config.cmd = M.command(root, config.cmd, config.name == "ruff" and "ruff" or nil)
      else
        vim.notify("direnv is unavailable; LSP started without a project environment", vim.log.levels.WARN)
      end
    end
    return start(config, opts)
  end
end

function M.setup()
  M.setup_lsp()
  vim.api.nvim_create_user_command("ProjectPythonSelect", function() python_env.pick(M.root()) end, {})
  vim.api.nvim_create_user_command("ProjectRuffSelect", function() python_env.pick(M.root(), true) end, {})
  vim.api.nvim_create_user_command("ProjectPythonInfo", function()
    local root = M.root()
    local choice = python_env.get(root)
    M.load_env(root, function(env, err)
      if not env then return vim.notify("Python environment: " .. tostring(err), vim.log.levels.ERROR) end
      local path, why = python.resolve(root, env)
      if not path then return vim.notify("Python environment: " .. tostring(why), vim.log.levels.ERROR) end
      local ruff = python_env.get_tool(root)
      vim.notify((choice and choice.label or "Automatic") .. ": " .. path .. " (" .. root .. "); Ruff: " .. (ruff and ruff.label or "automatic"))
    end)
  end, {})
  vim.api.nvim_create_user_command("ProjectEnvRefresh", function()
    envs.invalidate(M.root())
    vim.notify("Project environment cleared; restart existing language servers to reload it")
  end, {})
end

return M

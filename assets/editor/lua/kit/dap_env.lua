local M = {}
local project = require("kit.project")
local python = require("kit.python")

local function environment_list(env)
  local result = {}
  for key, value in pairs(env) do result[#result + 1] = key .. "=" .. value end
  return result
end

function M.adapter(command, args, is_python)
  return function(callback, config)
    local root = project.root(config.cwd)
    project.load_env(root, function(env, err)
      if not env then
        vim.notify("Cannot start debugger: " .. tostring(err), vim.log.levels.ERROR)
        return
      end
      local interpreter
      if is_python then
        interpreter, err = python.resolve(root, env)
        if not interpreter then
          vim.notify("Cannot start debugger: " .. tostring(err), vim.log.levels.ERROR)
          return
        end
      end
      callback({
        type = "executable",
        command = command,
        args = args,
        options = { cwd = root, env = environment_list(env) },
        enrich_config = is_python and function(cfg, on_config)
          cfg.pythonPath = nil
          cfg.python = interpreter
          cfg.console = "internalConsole"
          on_config(cfg)
        end or nil,
      })
    end)
  end
end

return M

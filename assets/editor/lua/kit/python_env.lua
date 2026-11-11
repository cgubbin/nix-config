local M = {}
local selected = {}
local selected_tools = {}
local uv = vim.uv or vim.loop

local function python(prefix)
  local path = prefix .. "/bin/python"
  return uv.fs_access(path, "X") and path or nil
end

function M.choices(root, tool)
  local result = {}
  local function suitable(path)
    return tool and uv.fs_access(path .. "/bin/ruff", "X") or (not tool and python(path))
  end
  if suitable(root .. "/.venv") then result[#result + 1] = { kind = "venv", path = root .. "/.venv", label = "uv / .venv" } end
  local parent = root .. "/.pixi/envs"
  local scan = uv.fs_scandir(parent)
  if scan then
    while true do
      local name, kind = uv.fs_scandir_next(scan)
      if not name then break end
      local path = parent .. "/" .. name
      if (kind == "directory" or kind == "link") and suitable(path) then
        result[#result + 1] = { kind = "pixi", name = name, path = path, label = "Pixi: " .. name }
      end
    end
  end
  local nox_parent = root .. "/.nox"
  scan = uv.fs_scandir(nox_parent)
  if scan then
    while true do
      local name, kind = uv.fs_scandir_next(scan)
      if not name then break end
      local path = nox_parent .. "/" .. name
      if (kind == "directory" or kind == "link") and suitable(path) then
        result[#result + 1] = { kind = "venv", path = path, label = "Nox: " .. name }
      end
    end
  end
  table.sort(result, function(a, b) return a.label < b.label end)
  return result
end

function M.set(root, choice)
  selected[root] = choice and vim.deepcopy(choice) or nil
end

function M.get(root)
  return selected[root] and vim.deepcopy(selected[root]) or nil
end

function M.set_tool(root, choice)
  selected_tools[root] = choice and vim.deepcopy(choice) or nil
end

function M.get_tool(root)
  local choice = selected_tools[root] or selected[root]
  return choice and vim.deepcopy(choice) or nil
end

function M.apply(root, env, callback)
  local choice = selected[root]
  if not choice then return callback(env) end
  if not python(choice.path) then return callback(nil, "Selected Python environment is missing: " .. choice.label) end
  local result = vim.deepcopy(env)
  if choice.kind == "venv" then
    result.VIRTUAL_ENV = choice.path
    result.PATH = choice.path .. "/bin:" .. (result.PATH or "")
    return callback(result)
  end
  local pixi
  for dir in (env.PATH or ""):gmatch("[^:]+") do
    local candidate = dir .. "/pixi"
    if uv.fs_access(candidate, "X") then pixi = candidate; break end
  end
  if not pixi then return callback(nil, "Pixi is unavailable in the project environment") end
  local started, err = pcall(vim.system,
    { pixi, "shell-hook", "--json", "--frozen", "--no-install", "--offline", "--manifest-path", root, "--environment", choice.name },
    { cwd = root, env = env, clear_env = true, text = true, timeout = 10000 }, function(out)
      vim.schedule(function()
        if selected[root] ~= choice then return callback(nil, "Python environment selection changed; retry") end
        if out.code ~= 0 then return callback(nil, "Pixi activation failed: " .. (out.stderr or "")) end
        local ok, variables = pcall(vim.json.decode, out.stdout or "")
        if not ok or type(variables) ~= "table" then return callback(nil, "Pixi returned invalid environment JSON") end
        for key, value in pairs(variables) do
          if type(value) == "string" then result[key] = value
          elseif value == vim.NIL then result[key] = nil
          else return callback(nil, "Pixi returned an invalid environment variable") end
        end
        result.VIRTUAL_ENV = choice.path
        callback(result)
      end)
    end)
  if not started then callback(nil, "Could not start Pixi: " .. tostring(err)) end
end

function M.pick(root, tool)
  local choices = M.choices(root, tool)
  table.insert(choices, 1, { kind = "automatic", label = tool and "Use selected Python environment" or "Automatic project environment" })
  vim.ui.select(choices, { prompt = (tool and "Ruff" or "Python") .. " environment (" .. root .. ")", format_item = function(item) return item.label end }, function(choice)
    if not choice then return end
    local selection = choice.kind ~= "automatic" and choice or nil
    if tool then M.set_tool(root, selection) else M.set(root, selection) end
    vim.notify("Selected " .. choice.label .. "; restart existing language servers to use it")
  end)
end

return M

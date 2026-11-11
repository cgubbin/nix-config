-- Project environments are values passed to subprocesses, never editor globals.
local M = {}
local base = vim.fn.environ()
local generations = {}
local cache = {}
local pending = {}

local function copy(value)
  return vim.deepcopy(value)
end

local function signature(root, env)
  local paths = {
    root .. "/.envrc", root .. "/.env", root .. "/pyproject.toml",
    root .. "/pixi.toml", root .. "/pixi.lock", root .. "/.venv/pyvenv.cfg",
  }
  if env and env.DIRENV_FILE then paths[#paths + 1] = env.DIRENV_FILE end
  local parts = {}
  for _, path in ipairs(paths) do
    local stat = (vim.uv or vim.loop).fs_stat(path)
    parts[#parts + 1] = stat and (path .. ":" .. stat.size .. ":" .. stat.mtime.sec .. ":" .. stat.mtime.nsec) or path .. ":missing"
  end
  return table.concat(parts, "\n")
end

function M.invalidate(root)
  generations[root] = (generations[root] or 0) + 1
  cache[root] = nil
  pending[root] = nil
end

function M.load(root, callback)
  if cache[root] then
    if cache[root].signature == signature(root, cache[root].env) then
      callback(copy(cache[root].env))
      return
    end
    M.invalidate(root)
  end
  if vim.fn.executable("direnv") ~= 1 then
    callback(nil, "direnv is not available")
    return
  end
  local initial_signature = signature(root)
  if pending[root] and pending[root].signature == initial_signature then
    table.insert(pending[root].callbacks, callback)
    return
  end
  generations[root] = (generations[root] or 0) + 1
  local generation = generations[root]
  local request = { signature = initial_signature, callbacks = { callback } }
  pending[root] = request
  local function finish(env, err)
    if pending[root] == request then pending[root] = nil end
    for _, cb in ipairs(request.callbacks) do cb(env and copy(env) or nil, err) end
  end
  local started, start_error = pcall(vim.system, { "direnv", "export", "json" }, {
    cwd = root,
    env = base,
    clear_env = true,
    text = true,
    timeout = 10000,
  }, function(result)
    vim.schedule(function()
      if generations[root] ~= generation then
        finish(nil, "project environment request superseded")
        return
      end
      if initial_signature ~= signature(root) then
        finish(nil, "project environment changed while loading; retry")
        return
      end
      if result.code ~= 0 then
        finish(nil, "direnv export failed; approve the environment or retry: " .. (result.stderr or ""))
        return
      end
      local ok, changes = pcall(vim.json.decode, result.stdout or "")
      if not ok or type(changes) ~= "table" then
        finish(nil, "direnv returned invalid JSON")
        return
      end
      local env = copy(base)
      for key, value in pairs(changes) do
        if type(value) == "string" then
          env[key] = value
        elseif value == vim.NIL then
          env[key] = nil
        else
          finish(nil, "direnv returned an invalid environment value for " .. tostring(key))
          return
        end
      end
      cache[root] = { env = env, signature = signature(root, env) }
      finish(env)
    end)
  end)
  if not started then
    finish(nil, "could not start direnv: " .. tostring(start_error))
  end
end

return M

local M = {}
local uv = vim.uv or vim.loop

local function executable(path)
  if not path or path == "" or not uv.fs_access(path, "X") then return false end
  local stat = uv.fs_stat(path)
  return stat ~= nil and stat.type == "file"
end

local function find_executable(name, env)
  for dir in (env.PATH or ""):gmatch("[^:]+") do
    local path = dir .. "/" .. name
    if executable(path) then return path end
  end
end

local function pixi_manifest(root)
  local pixi = root .. "/pixi.toml"
  if uv.fs_stat(pixi) then return pixi end
  local pyproject = root .. "/pyproject.toml"
  if not uv.fs_stat(pyproject) then return nil end
  for _, line in ipairs(vim.fn.readfile(pyproject)) do
    if line:match("^%s*%[tool%.pixi[%.%]]") then return pyproject end
  end
end

function M.resolve(root, env)
  if env.VIRTUAL_ENV then
    local venv = env.VIRTUAL_ENV .. "/bin/python"
    if executable(venv) then return venv end
  end
  local manifest = pixi_manifest(root)
  local pixi = manifest and find_executable("pixi", env)
  if pixi then
    local result
    local ok, process = pcall(vim.system,
      { pixi, "run", "--frozen", "--offline", "--manifest-path", manifest, "which", "python" },
      { cwd = root, env = env, clear_env = true, text = true },
      function(value) result = value end)
    if ok and not vim.wait(1500, function() return result ~= nil end, 10) then
      pcall(function() process:kill(9) end)
    end
    local path = result and result.code == 0 and vim.trim(result.stdout or "") or nil
    if executable(path) then return path end
  end
  local venv = root .. "/.venv/bin/python"
  if executable(venv) then return venv end
  local python = find_executable("python3", env) or find_executable("python", env)
  if python then return python end
  return nil, "No executable Python found for " .. root
end

return M

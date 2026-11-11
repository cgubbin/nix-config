local python = dofile((vim.env.NIXVIM_EDITOR_ASSETS or "assets/editor") .. "/lua/kit/python.lua")
local uv = vim.uv or vim.loop
local dir = vim.fn.tempname()
vim.fn.mkdir(dir .. "/bin", "p")
vim.fn.mkdir(dir .. "/.venv/bin", "p")
local function executable(path)
  vim.fn.writefile({ "#!/bin/sh", "exit 0" }, path)
  assert(uv.fs_chmod(path, 493))
end
local fallback = dir .. "/bin/python3"
local venv = dir .. "/.venv/bin/python"
executable(fallback)
executable(venv)
local env = { PATH = dir .. "/bin" }
local alternate = dir .. "/other-env/bin/python"
vim.fn.mkdir(dir .. "/other-env/bin", "p")
executable(alternate)
assert(python.resolve(dir, { PATH = env.PATH, VIRTUAL_ENV = dir .. "/other-env" }) == alternate)
assert(python.resolve(dir, { PATH = env.PATH, VIRTUAL_ENV = dir .. "/missing-env" }) == venv)
local old_system = vim.system
local calls = 0
vim.system = function(_, _, callback)
  calls = calls + 1
  callback({ code = 0, stdout = fallback .. "\n" })
  return { kill = function() end }
end
vim.fn.writefile({ "[project]", 'name = "plain"' }, dir .. "/pyproject.toml")
assert(python.resolve(dir, env) == venv and calls == 0)
executable(dir .. "/bin/pixi")
assert(python.resolve(dir, env) == venv and calls == 0)
vim.fn.writefile({ "[tool.pixi.project]" }, dir .. "/pyproject.toml")
assert(python.resolve(dir, env) == fallback and calls == 1)
vim.system = function(_, _, callback) callback({ code = 124 }); return { kill = function() end } end
assert(python.resolve(dir, env) == venv)
vim.system = old_system
local sleep = vim.fn.exepath("sleep")
assert(sleep ~= "", "sleep is required for the timeout check")
vim.fn.writefile({ "#!/bin/sh", vim.fn.shellescape(sleep) .. " 4" }, dir .. "/bin/pixi")
local start = uv.hrtime()
assert(python.resolve(dir, env) == venv)
assert((uv.hrtime() - start) / 1e9 < 3, "slow Pixi did not time out")
vim.system = function(_, _, callback) callback({ code = 124 }); return { kill = function() end } end
vim.fn.delete(venv)
assert(python.resolve(dir, env) == fallback)
vim.fn.delete(fallback)
local missing, err = python.resolve(dir, { PATH = "" })
assert(not missing and err)
vim.system = old_system
vim.fn.delete(dir, "rf")

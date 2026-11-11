local envs = require("kit.python_env")
local uv = vim.uv or vim.loop
local root = assert(vim.env.NIXVIM_TEST_DIR) .. "/selected env"
local function environment(prefix)
  vim.fn.mkdir(prefix .. "/bin", "p")
  vim.fn.writefile({ "#!/bin/sh", "exit 0" }, prefix .. "/bin/python")
  assert(uv.fs_chmod(prefix .. "/bin/python", 493))
end
environment(root .. "/.venv")
environment(root .. "/.pixi/envs/science")
local choices = envs.choices(root)
assert(#choices == 2)
local venv, pixi
for _, item in ipairs(choices) do if item.kind == "venv" then venv = item else pixi = item end end
envs.set(root, venv)
local value, err
envs.apply(root, { PATH = "/base" }, function(v, e) value, err = v, e end)
assert(value.VIRTUAL_ENV == venv.path and value.PATH == venv.path .. "/bin:/base" and not err)
assert(envs.get(root .. "/other") == nil, "selection leaked to another project")
local pixibin = root .. "/pixibin"
vim.fn.mkdir(pixibin, "p")
vim.fn.writefile({
  "#!/bin/sh",
  'for flag in --frozen --no-install --offline science; do case " $* " in *" $flag "*) ;; *) exit 9;; esac; done',
  'printf \'{"PIXI_ENVIRONMENT_NAME":"science","PATH":"/pixi/bin"}\'',
}, pixibin .. "/pixi")
assert(uv.fs_chmod(pixibin .. "/pixi", 493))
envs.set(root, pixi)
value, err = nil, nil
envs.apply(root, { PATH = pixibin }, function(v, e) value, err = v, e end)
assert(vim.wait(3000, function() return value or err end), "Pixi activation timed out")
assert(value and value.PIXI_ENVIRONMENT_NAME == "science" and value.VIRTUAL_ENV == pixi.path, tostring(err))
local original_system, callback = vim.system
vim.system = function(_, _, cb) callback = cb; return {} end
value, err = nil, nil
envs.apply(root, { PATH = pixibin }, function(v, e) value, err = v, e end)
envs.set(root, venv)
callback({ code = 0, stdout = "{}" })
assert(vim.wait(3000, function() return err end) and err:find("changed"), "stale Pixi activation must be rejected")
vim.system = original_system
envs.set(root, pixi)
vim.fn.delete(pixi.path .. "/bin/python")
value, err = nil, nil
envs.apply(root, { PATH = pixibin }, function(v, e) value, err = v, e end)
assert(not value and err:find("missing"), "missing selection must not silently fall back")
envs.set(root, nil)

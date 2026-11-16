-- Project kernels: generated kernelspecs on JUPYTER_PATH, per root and
-- interpreter, carrying the project environment, with actionable errors and no
-- writes into the project.
local kernel = require("kit.kernel")
local project = require("kit.project")
local python_env = require("kit.python_env")
local uv = vim.uv or vim.loop
local base = assert(vim.env.NIXVIM_TEST_DIR) .. "/kernels"

-- setup() ran during init: the spec directory is on JUPYTER_PATH exactly once.
assert((vim.env.JUPYTER_PATH or ""):find(kernel.dir, 1, true) == 1, "kernel dir not first on JUPYTER_PATH: " .. tostring(vim.env.JUPYTER_PATH))
kernel.setup()
local _, count = (vim.env.JUPYTER_PATH):gsub(vim.pesc(kernel.dir), "")
assert(count == 1, "setup() must not add the kernel dir twice")
assert(vim.fn.isdirectory(vim.env.JUPYTER_RUNTIME_DIR or "") == 1, "Jupyter runtime dir missing: " .. tostring(vim.env.JUPYTER_RUNTIME_DIR))

local host = assert(vim.g.python3_host_prog, "python3_host_prog unset")
local bare = assert(vim.env.NIXVIM_TEST_PYTHON, "NIXVIM_TEST_PYTHON unset")

local function fake_python(prefix, target)
  vim.fn.mkdir(prefix .. "/bin", "p")
  vim.fn.writefile({ "#!/bin/sh", 'exec "' .. target .. '" "$@"' }, prefix .. "/bin/python")
  assert(uv.fs_chmod(prefix .. "/bin/python", 493))
end

local function project_dir(name, opts)
  local root = base .. "/" .. name
  vim.fn.mkdir(root, "p")
  vim.fn.writefile({ "[project]", 'name = "' .. name .. '"' }, root .. "/pyproject.toml")
  if opts.uv_lock then vim.fn.writefile({ "version = 1" }, root .. "/uv.lock") end
  for _, env in ipairs(opts.pixi or {}) do fake_python(root .. "/.pixi/envs/" .. env, host) end
  if opts.venv then fake_python(root .. "/.venv", opts.venv) end
  return root
end

local function listing(dir)
  local out = {}
  for name in vim.fs.dir(dir, { depth = 10 }) do out[#out + 1] = name end
  table.sort(out)
  return table.concat(out, "\n")
end

-- The project environment comes from kit.project; stub direnv out.
local load_env = project.load_env
project.load_env = function(root, callback)
  local env = vim.fn.environ()
  env.KIT_TEST_PROJECT = root
  python_env.apply(root, env, callback)
end

local function prepare(root)
  local result
  kernel.prepare(root, function(info, err) result = { info = info, err = err } end)
  assert(vim.wait(30000, function() return result ~= nil end, 20), "prepare timed out for " .. root)
  return result.info, result.err
end

-- Two worktrees of one project get distinct kernels on their own interpreters.
local a = project_dir("wt-a", { venv = host, uv_lock = true })
local b = project_dir("wt-b", { venv = host, uv_lock = true })
local before_a = listing(a)
local info_a, err_a = prepare(a)
local info_b, err_b = prepare(b)
assert(info_a and info_b, tostring(err_a or err_b))
assert(info_a.name ~= info_b.name, "worktrees share a kernel name")
assert(info_a.python == a .. "/.venv/bin/python", info_a.python)
assert(kernel.name(a, info_a.python) == info_a.name, "kernel name is not stable")
assert(listing(a) == before_a, "prepare wrote into the project")

local spec = vim.json.decode(table.concat(vim.fn.readfile(kernel.dir .. "/kernels/" .. info_a.name .. "/kernel.json"), "\n"))
assert(spec.argv[1] == info_a.python and spec.argv[3] == "ipykernel_launcher", vim.inspect(spec.argv))
assert(spec.env.KIT_TEST_PROJECT == a, "project environment missing from spec")
assert(spec.metadata.kit.root == a)

-- A spec written after startup is visible to Molten.
local available = vim.fn.MoltenAvailableKernels()
assert(vim.tbl_contains(available, info_a.name), "Molten does not list " .. info_a.name .. ": " .. vim.inspect(available))

-- Missing ipykernel: actionable error, no kernelspec, no fallback.
local missing = project_dir("no-ipykernel", { venv = bare, uv_lock = true })
local info, err = prepare(missing)
assert(not info and err:find("ipykernel is not installed", 1, true) and err:find("uv add --dev ipykernel", 1, true), tostring(err))
assert(vim.fn.isdirectory(kernel.dir .. "/kernels/" .. kernel.name(missing, missing .. "/.venv/bin/python")) == 0, "spec written despite failure")

-- Several Pixi environments without a selection: ask, don't guess.
local pixi = project_dir("two-pixi", { pixi = { "default", "gpu" } })
info, err = prepare(pixi)
assert(not info and err:find("NotebookKernelSelect", 1, true), tostring(err))
for _, choice in ipairs(python_env.choices(pixi)) do
  if choice.name == "gpu" then python_env.set(pixi, choice) end
end
assert(not kernel.ambiguous(pixi), "an explicit selection must resolve ambiguity")

-- A uv .venv alongside Nox sessions is not ambiguous.
local nox = project_dir("venv-and-nox", { venv = host, uv_lock = true })
fake_python(nox .. "/.nox/tests", host)
assert(not kernel.ambiguous(nox), "Nox environments must not make a project ambiguous")

-- End to end: a buffer in a project with a real venv gets a kernel on that
-- venv's interpreter (sys.executable is only meaningful for a real venv).
local real = vim.trim(vim.fn.system({ host, "-c", "import sys; print(sys.executable)" }))
local e2e = base .. "/e2e"
vim.fn.mkdir(e2e, "p")
vim.fn.writefile({ "version = 1" }, e2e .. "/uv.lock")
vim.fn.system({ real, "-m", "venv", "--system-site-packages", "--without-pip", e2e .. "/.venv" })
assert(vim.v.shell_error == 0, "could not create a test venv from " .. real)
a = e2e
local root_of = project.root
project.root = function() return a end
local marker = base .. "/executable.txt"
vim.cmd("enew")
local buf = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
  "import sys",
  "open(" .. string.format("%q", marker) .. ", 'w').write(sys.executable)",
})
local started
local notes = {}
local notify = vim.notify
vim.notify = function(msg, ...) notes[#notes + 1] = tostring(msg); return notify(msg, ...) end
kernel.start(buf, function(value, start_err) started = { info = value, err = start_err } end)
assert(vim.wait(60000, function() return started ~= nil end, 50), "kernel start timed out")
vim.notify = notify
assert(started.info, "kernel start failed: " .. tostring(started.err) .. "\n" .. table.concat(notes, "\n"))
vim.fn.MoltenEvaluateRange(started.info.name, 1, 2)
assert(vim.wait(60000, function() return vim.fn.filereadable(marker) == 1 end, 100), "cell did not run")
local executable = vim.fn.readfile(marker)[1]
assert(executable:find(a, 1, true) == 1, "cell ran in " .. executable .. ", not in " .. a)
pcall(vim.cmd, "MoltenDeinit")
project.root = root_of

project.load_env = load_env
python_env.set(pixi, nil)

local base = assert(vim.env.NIXVIM_TEST_DIR)
local python = assert(vim.env.NIXVIM_TEST_PYTHON)
local check = vim.system({ python, "-c", "import importlib.util; assert importlib.util.find_spec('xdist') is None" }):wait()
assert(check.code == 0, "test Python unexpectedly contains pytest-xdist")
local function make_project(name, removed)
  local root = base .. "/python " .. name
  local marker = root .. "/runs.txt"
  vim.fn.mkdir(root .. "/.venv/bin", "p")
  assert((vim.uv or vim.loop).fs_symlink(python, root .. "/.venv/bin/python"))
  vim.fn.writefile({ "[tool.pytest.ini_options]" }, root .. "/pyproject.toml")
  local rc = {
    "export VIRTUAL_ENV=" .. vim.fn.shellescape(root .. "/.venv"),
    "export NIXVIM_PROJECT=" .. name,
    "export NIXVIM_MARKER=" .. vim.fn.shellescape(marker),
    removed and "unset NIXVIM_REMOVE" or "export NIXVIM_REMOVE=from-b",
  }
  vim.fn.writefile(rc, root .. "/.envrc")
  local test = {
    "import os",
    "def test_project_environment():",
    "    assert os.environ['NIXVIM_PROJECT'] == '" .. name .. "'",
    removed and "    assert 'NIXVIM_REMOVE' not in os.environ" or "    assert os.environ['NIXVIM_REMOVE'] == 'from-b'",
    "    with open(os.environ['NIXVIM_MARKER'], 'a') as marker:",
    "        marker.write('passed\\n')",
  }
  local path = root .. "/test_project.py"
  vim.fn.writefile(test, path)
  assert(vim.system({ "direnv", "allow", root }, { text = true }):wait().code == 0)
  return { root = root, file = path, marker = marker }
end
local a = make_project("A", true)
local b = make_project("B", false)
local neotest = require("neotest")
local function run(project, expected)
  vim.fn.chdir(project.root)
  vim.cmd("edit " .. vim.fn.fnameescape(project.file))
  neotest.run.run(project.file)
  local done = vim.wait(30000, function()
    return vim.fn.filereadable(project.marker) == 1 and #vim.fn.readfile(project.marker) == expected
  end, 50)
  if not done then
    for _, path in ipairs(vim.fn.glob(vim.fn.stdpath("state") .. "/**/*neotest*", true, true)) do
      if vim.fn.filereadable(path) == 1 then
        print(path .. "\n" .. table.concat(vim.fn.readfile(path), "\n"))
      end
    end
    error("Neotest did not pass project " .. project.root)
  end
end
run(a, 1)
run(b, 1)
run(a, 2)
assert(vim.env.NIXVIM_REMOVE == "base", "editor environment changed")

local dap = require("dap")
-- The UI is interactive; exercise the adapter and target in headless mode.
dap.listeners.after.event_initialized.dapui_config = nil
dap.listeners.before.event_terminated.dapui_config = nil
dap.listeners.before.event_exited.dapui_config = nil
local function debug_project(project, expected)
  local marker = project.root .. "/debug.txt"
  local script = project.root .. "/debug.py"
  vim.fn.writefile({
    "import os, sys",
    "with open(" .. string.format("%q", marker) .. ", 'a') as f:",
    "    f.write(os.environ['NIXVIM_PROJECT'] + ':' + os.environ.get('NIXVIM_REMOVE', 'unset') + ':' + sys.executable + '\\n')",
  }, script)
  vim.fn.chdir(project.root)
  dap.run({ type = "python", request = "launch", name = "project test", program = script, cwd = project.root })
  local done = vim.wait(30000, function()
    return vim.fn.filereadable(marker) == 1 and #vim.fn.readfile(marker) == expected
  end, 50)
  assert(done, "debug target did not run for " .. project.root .. "; see " .. vim.fn.stdpath("cache") .. "/dap.log")
  local line = vim.fn.readfile(marker)[expected]
  local want = project == a and "A:unset:" or "B:from-b:"
  assert(line == want .. project.root .. "/.venv/bin/python", "unexpected debugger environment: " .. line)
  assert(vim.wait(10000, function() return dap.session() == nil end, 50), "debug session did not terminate")
end
debug_project(a, 1)
debug_project(b, 1)
debug_project(a, 2)
assert(vim.env.NIXVIM_REMOVE == "base", "debugging changed the editor environment")

local function lsp_project(project, expected)
  vim.fn.chdir(project.root)
  vim.cmd("edit " .. vim.fn.fnameescape(project.file))
  local marker = project.marker .. ".lsp"
  local client = vim.lsp.start({
    name = "project-environment-fixture",
    root_dir = project.root,
    cmd = { "sh", "-c", 'printf "%s:%s\\n" "$NIXVIM_PROJECT" "${NIXVIM_REMOVE-unset}" >> "$NIXVIM_MARKER.lsp"; sleep 2' },
  }, { reuse_client = function() return false end })
  assert(client, "LSP fixture failed to start")
  assert(vim.wait(10000, function()
    return vim.fn.filereadable(marker) == 1 and #vim.fn.readfile(marker) == expected
  end, 50), "LSP did not start in project environment")
  assert(vim.fn.readfile(marker)[expected] == (project == a and "A:unset" or "B:from-b"))
  vim.lsp.stop_client(client, true)
end
lsp_project(a, 1)
lsp_project(b, 1)
lsp_project(a, 2)

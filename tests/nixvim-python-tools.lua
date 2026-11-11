local root = assert(vim.env.NIXVIM_TEST_DIR) .. "/python tools"
local uv = vim.uv or vim.loop
vim.fn.mkdir(root .. "/.venv/bin", "p")
vim.fn.mkdir(root .. "/.nox/lint/bin", "p")
vim.fn.writefile({}, root .. "/pyproject.toml")
vim.fn.writefile({ "export PROJECT_TOOL_MARKER=approved", "export PROJECT_TOOL_OUTPUT=" .. vim.fn.shellescape(root .. "/lsp-environment") }, root .. "/.envrc")
vim.fn.writefile({
  "#!/bin/sh", 'test "$PROJECT_TOOL_MARKER" = approved || exit 9',
  'if test "$1" = server; then printf "%s" "$VIRTUAL_ENV" > "$PROJECT_TOOL_OUTPUT"; sleep 2; exit; fi',
  'printf "formatted\\n"',
}, root .. "/.nox/lint/bin/ruff")
vim.fn.writefile({ "#!/bin/sh", "exit 0" }, root .. "/.venv/bin/python")
assert(uv.fs_chmod(root .. "/.nox/lint/bin/ruff", 493))
assert(uv.fs_chmod(root .. "/.venv/bin/python", 493))
assert(vim.system({ "direnv", "allow", root }):wait().code == 0)
local choice = { kind = "venv", path = root .. "/.venv", label = "fixture" }
require("kit.python_env").set(root, choice)
local tools = require("kit.python_env")
local lint = { kind = "venv", path = root .. "/.nox/lint", label = "lint group" }
tools.set_tool(root, lint)
assert(#tools.choices(root, true) == 1, "Ruff-only environment should be discoverable")
local project = require("kit.project")
assert(project.python_tool(root, "ruff") == lint.path .. "/bin/ruff")
assert(not pcall(project.python_tool, root, "missing-tool"), "missing project tool silently fell back")
local path = root .. "/example.py"
vim.fn.writefile({ "before" }, path)
vim.cmd("edit " .. vim.fn.fnameescape(path))
vim.bo.filetype = "python"
local client = vim.lsp.start({ name = "ruff", root_dir = root, cmd = { "ignored-ruff", "server" } }, { reuse_client = function() return false end })
assert(client, "Ruff LSP did not start")
assert(vim.wait(10000, function()
  return vim.fn.filereadable(root .. "/lsp-environment") == 1 and #vim.fn.readfile(root .. "/lsp-environment") > 0
end), "Ruff LSP did not run")
assert(vim.fn.readfile(root .. "/lsp-environment")[1] == lint.path, "Ruff LSP used the wrong environment")
vim.lsp.stop_client(client, true)
local done, failure = false
require("conform").format({ bufnr = 0, async = true, formatters = { "ruff_format" } }, function(err)
  failure, done = err, true
end)
assert(vim.wait(10000, function() return done end), "formatting timed out")
assert(not failure, "formatting failed: " .. tostring(failure))
assert(vim.api.nvim_buf_get_lines(0, 0, -1, false)[1] == "formatted", "formatter did not use project tool")
require("kit.python_env").set(root, nil)
tools.set_tool(root, nil)

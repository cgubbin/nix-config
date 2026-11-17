-- Saving an .ipynb writes the kernel's outputs into that file (never a sibling
-- copy-of-*.ipynb) and keeps notebook metadata; reopening loads stored outputs.
local kernel = require("kit.kernel")
-- Headless runs have no terminal size, so Molten's image placement fails on
-- every tick and keeps its host busy. Image outputs are still recorded and
-- saved as data; they are just not drawn.
vim.fn.MoltenUpdateOption("image_provider", "none")
local project = require("kit.project")
local python_env = require("kit.python_env")

local root = assert(vim.env.NIXVIM_TEST_DIR) .. "/ipynb-outputs"
vim.fn.mkdir(root, "p")
vim.fn.writefile({ "version = 1" }, root .. "/uv.lock")
local host = assert(vim.g.python3_host_prog)
local real = vim.trim(vim.fn.system({ host, "-c", "import sys; print(sys.executable)" }))
vim.fn.system({ real, "-m", "venv", "--system-site-packages", "--without-pip", root .. "/.venv" })
assert(vim.v.shell_error == 0, "could not create a test venv")

local root_of, load_env = project.root, project.load_env
project.root = function() return root end
project.load_env = function(r, callback) python_env.apply(r, vim.fn.environ(), callback) end

local path = root .. "/analysis.ipynb"
local marker = root .. "/ran.txt"
-- Text, image and error outputs; the image cell writes the marker last.
local png = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
local cells_code = {
  { "x = 6 * 7", "print(x)" },
  { "import base64", "from IPython.display import Image, display",
    "display(Image(data=base64.b64decode(" .. string.format("%q", png) .. ")))",
    "open(" .. string.format("%q", marker) .. ", 'w').write('done')" },
  { "raise ValueError('boom')" },
}
local function source(lines)
  local out = {}
  for i, line in ipairs(lines) do out[i] = line .. (i < #lines and "\n" or "") end
  return out
end
local nb_cells = { { cell_type = "markdown", metadata = vim.empty_dict(), source = { "# Title" } } }
for _, lines in ipairs(cells_code) do
  nb_cells[#nb_cells + 1] = { cell_type = "code", execution_count = vim.NIL, metadata = vim.empty_dict(), outputs = {}, source = source(lines) }
end
vim.fn.writefile({ vim.json.encode({
  cells = nb_cells,
  metadata = {
    kernelspec = { display_name = "Python 3", language = "python", name = "python3" },
    kit_keep = "preserved",
  },
  nbformat = 4,
  nbformat_minor = 5,
}) }, path)

local function start(buf)
  local result
  kernel.start(buf, function(info, err) result = { info = info, err = err } end)
  assert(vim.wait(60000, function() return result ~= nil end, 50), "kernel start timed out")
  assert(result.info, "kernel start failed: " .. tostring(result.err))
  return result.info
end

vim.cmd("edit " .. vim.fn.fnameescape(path))
local buf = vim.api.nvim_get_current_buf()
vim.bo[buf].undofile = false
local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
local function find(line)
  for i, text in ipairs(lines) do
    if text == line then return i end
  end
  error("code not found in the converted buffer: " .. line .. "\n" .. vim.inspect(lines))
end

local info = start(buf)
for _, cell_lines in ipairs(cells_code) do
  local first = find(cell_lines[1])
  vim.fn.MoltenEvaluateRange(info.name, first, first + #cell_lines - 1)
end
assert(vim.wait(60000, function() return vim.fn.filereadable(marker) == 1 end, 100), "cells did not run")
-- Outputs reach Molten asynchronously, so save until all three kinds are in
-- the file rather than sleeping a fixed time.
local saved
local function has(cell, needle)
  return vim.json.encode(saved.cells[cell].outputs):find(needle, 1, true) ~= nil
end
assert(vim.wait(30000, function()
  vim.cmd("write")
  saved = vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
  return has(2, "42") and has(3, "image/png") and has(4, '"error"') and has(4, "boom")
end, 500), "outputs not saved into the notebook: " .. vim.inspect(saved and vim.tbl_map(function(c) return c.outputs end, saved.cells)))
assert(saved.metadata.kit_keep == "preserved", "notebook metadata lost: " .. vim.inspect(saved.metadata))
assert(saved.cells[1].cell_type == "markdown", "markdown cell lost")
for _, name in ipairs(vim.fn.readdir(root)) do
  assert(not name:match("^copy%-of%-"), "export wrote a sibling file: " .. name)
end

-- `v`: the plot of the cell under the cursor opens in the system viewer.
local ui_open, opened = vim.ui.open, nil
vim.ui.open = function(target) opened = target; return {}, nil end
vim.api.nvim_win_set_cursor(0, { find(cells_code[2][3]), 0 })
local plot = kernel.view_plot(buf)
vim.ui.open = ui_open
assert(plot and opened, "view_plot did not open anything")
local bytes = assert(io.open(plot, "rb")):read(8)
assert(bytes == "\137PNG\r\n\26\n", "view_plot did not write a PNG: " .. vim.inspect(bytes))
assert(plot:find(kernel.dir, 1, true) == 1, "plot written outside the run directory: " .. plot)
-- A cell without a plot says so instead of opening something else.
vim.api.nvim_win_set_cursor(0, { find(cells_code[1][1]), 0 })
opened = nil
vim.ui.open = function(target) opened = target; return {}, nil end
kernel.view_plot(buf)
vim.ui.open = ui_open
assert(opened == nil, "a cell without a plot opened " .. tostring(opened))

-- Reopen: saved outputs load on request (:NotebookLoadOutputs), without errors.
pcall(vim.cmd, "MoltenDeinit")
-- Molten finishes tearing down asynchronously; starting the next kernel while
-- it is still deleting the old buffer's marks intermittently failed init.
vim.wait(2000, function() return #vim.fn.MoltenRunningKernels(false) == 0 end, 100)
vim.wait(500)
vim.cmd("bwipeout!")
local warnings = {}
local notify = vim.notify
vim.notify = function(msg, level, ...)
  -- Only notebook-related warnings; other plugins complain about the missing LSP.
  local text = tostring(msg)
  if level and level >= vim.log.levels.WARN and (text:find("output") or text:find("Molten") or text:find("kernel")) then
    warnings[#warnings + 1] = text
  end
  return notify(msg, level, ...)
end
vim.cmd("edit " .. vim.fn.fnameescape(path))
local reopened = vim.api.nvim_get_current_buf()
start(reopened)
vim.cmd("NotebookLoadOutputs")
-- The import is deferred (and retried while Molten's host is busy); give it
-- the full retry window before checking for warnings.
vim.wait(kernel.import_retries * kernel.import_delay + 1000)
local loaded = #vim.api.nvim_buf_get_extmarks(reopened, -1, 0, -1, {})
assert(loaded > 0, "no saved outputs were shown after :NotebookLoadOutputs")
vim.notify = notify
assert(#warnings == 0, "reopening raised: " .. table.concat(warnings, "\n"))

pcall(vim.cmd, "MoltenDeinit")
vim.cmd("bwipeout!")
project.root, project.load_env = root_of, load_env

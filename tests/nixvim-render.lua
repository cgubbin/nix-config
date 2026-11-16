-- :NotebookRender renders into stdpath("run") with the project's quarto, opens
-- the HTML, and leaves the project untouched.
local render = require("kit.render")
local project = require("kit.project")
local uv = vim.uv or vim.loop

local root = assert(vim.env.NIXVIM_TEST_DIR) .. "/render-project"
local bin = assert(vim.env.NIXVIM_TEST_DIR) .. "/render-bin"
vim.fn.mkdir(root, "p")
vim.fn.mkdir(bin, "p")
vim.fn.writefile({ "[project]", 'name = "render"' }, root .. "/pyproject.toml")

-- Fake quarto: records its arguments and writes <stem>.html into its cwd.
local log = bin .. "/quarto.log"
vim.fn.writefile({
  "#!/bin/sh",
  'echo "$PWD|$*" >> ' .. vim.fn.shellescape(log),
  't=$(basename "$2"); echo "<html></html>" > "$PWD/${t%.*}.html"',
}, bin .. "/quarto")
assert(uv.fs_chmod(bin .. "/quarto", 493))

vim.fn.writefile({ vim.json.encode({
  cells = { { cell_type = "code", execution_count = 1, metadata = vim.empty_dict(), outputs = {}, source = { "1 + 1" } } },
  metadata = { kernelspec = { display_name = "Python 3", language = "python", name = "python3" } },
  nbformat = 4, nbformat_minor = 5,
}) }, root .. "/stored.ipynb")
vim.fn.writefile({ "# %%", "x = 1", "", "# %%", "print(x)" }, root .. "/analysis.py")
vim.fn.writefile({ "---", "title: Report", "---", "", "Text." }, root .. "/report.qmd")

local function listing(dir)
  local out = {}
  for name in vim.fs.dir(dir, { depth = 10 }) do out[#out + 1] = name end
  table.sort(out)
  return table.concat(out, "\n")
end
local before = listing(root)

local root_of, load_env, ui_open = project.root, project.load_env, vim.ui.open
local with_quarto = true
project.root = function() return root end
project.load_env = function(_, callback)
  local env = vim.fn.environ()
  if with_quarto then env.PATH = bin .. ":" .. env.PATH end
  callback(env)
end
local opened
vim.ui.open = function(path) opened = path; return {}, nil end

local function run(file)
  vim.cmd("edit " .. vim.fn.fnameescape(root .. "/" .. file))
  vim.bo.undofile = false
  local result
  render.render(0, function(value, err) result = { value = value, err = err } end)
  assert(vim.wait(60000, function() return result ~= nil end, 50), "render timed out: " .. file)
  vim.cmd("bwipeout!")
  return result.value, result.err
end

for _, case in ipairs({
  { file = "stored.ipynb", flag = "--no-execute", source = "stored.ipynb" },
  { file = "analysis.py", flag = "--no-execute", source = "analysis.ipynb" },
  { file = "report.qmd", flag = "--execute-dir " .. root, source = "report.qmd" },
}) do
  vim.fn.delete(log)
  opened = nil
  local value, err = run(case.file)
  assert(value, case.file .. ": " .. tostring(err))
  assert(value.html:find(render.dir, 1, true) == 1, "rendered outside the run directory: " .. value.html)
  assert(opened == value.html, "opened " .. tostring(opened) .. " instead of " .. value.html)
  local call = vim.fn.readfile(log)[1]
  assert(call:find("render " .. vim.fs.dirname(value.html) .. "/" .. case.source, 1, true), case.file .. ": " .. call)
  assert(call:find(case.flag, 1, true), case.file .. " missing " .. case.flag .. ": " .. call)
  assert(call:find(render.dir, 1, true) == 1, "quarto ran outside the run directory: " .. call)
end
assert(listing(root) == before, "rendering changed the project:\n" .. listing(root))

-- No quarto in the project environment: a clear error, no browser.
with_quarto, opened = false, nil
local value, err = run("report.qmd")
assert(not value and err:find("quarto is not available", 1, true) and opened == nil, tostring(err))

project.root, project.load_env, vim.ui.open = root_of, load_env, ui_open

local notebook = dofile((vim.env.NIXVIM_EDITOR_ASSETS or "assets/editor") .. "/lua/kit/notebook.lua")
local dir = vim.fn.tempname()
vim.fn.mkdir(dir, "p")
local name = dir .. "/notebook with spaces"
local path = name .. ".ipynb"

assert(notebook.create(name))
local original = table.concat(vim.fn.readfile(path), "\n")
local parsed = vim.json.decode(original)
assert(parsed.nbformat == 4 and parsed.cells[1].cell_type == "markdown")

vim.fn.writefile({ "existing content" }, path)
notebook.confirm_replace = function() return false end
assert(not notebook.create(name))
assert(vim.fn.readfile(path)[1] == "existing content")

notebook.confirm_replace = function() return true end
assert(notebook.create(name))
assert(vim.json.decode(table.concat(vim.fn.readfile(path), "\n")).nbformat == 4)
vim.fn.delete(dir, "rf")

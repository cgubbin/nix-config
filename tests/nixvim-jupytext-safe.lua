local dir = assert(vim.env.NIXVIM_TEST_DIR)
local notebook = {
  cells = { { cell_type = "markdown", metadata = vim.empty_dict(), source = { "notebook-only" } } },
  metadata = {
    kernelspec = { display_name = "Python 3", language = "python", name = "python3" },
    language_info = { name = "python" },
  },
  nbformat = 4,
  nbformat_minor = 5,
}
local path = dir .. "/notebook with spaces.ipynb"
local sibling = dir .. "/notebook with spaces.md"
vim.fn.writefile({ vim.json.encode(notebook) }, path)
vim.fn.writefile({ "unrelated markdown sentinel" }, sibling)
vim.cmd("edit " .. vim.fn.fnameescape(path))
local contents = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
assert(contents:find("notebook%-only") and not contents:find("sentinel"), contents)
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# first notebook change" })
vim.cmd.write()
vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# second notebook change" })
vim.cmd.write()
local result = vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
assert(vim.json.encode(result):find("second notebook change", 1, true), "notebook save failed")
assert(vim.fn.readfile(sibling)[1] == "unrelated markdown sentinel", "sibling Markdown was overwritten")
vim.cmd("bdelete!")
assert(vim.fn.readfile(sibling)[1] == "unrelated markdown sentinel", "sibling Markdown was removed")

local other = dir .. "/another.ipynb"
vim.fn.writefile({ vim.json.encode(notebook) }, other)
vim.cmd("edit " .. vim.fn.fnameescape(other))
vim.cmd.write()
assert(vim.fn.filereadable(dir .. "/another.md") == 0, "adjacent temporary Markdown was created")
vim.cmd("bdelete!")
assert(vim.fn.filereadable(dir .. "/another.md") == 0, "adjacent temporary Markdown was created")

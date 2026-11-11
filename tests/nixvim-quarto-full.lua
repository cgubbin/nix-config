local dir = assert(vim.env.NIXVIM_TEST_DIR)
local first = dir .. "/preview with spaces.qmd"
vim.fn.writefile({ "---", "title: Test", "---", "", "# Preview" }, first)
vim.cmd("edit " .. vim.fn.fnameescape(first))
vim.cmd("set filetype=quarto")
assert(vim.g.quarto_sync_fixture_setups == 1, "Quarto fixture did not initialize")
local mapping = vim.fn.maparg(",rp", "n", false, true)
assert(type(mapping.callback) == "function", "preview mapping missing")
mapping.callback()
assert(vim.g.quarto_sync_fixture_preview == dir .. "/copy-of-preview with spaces.qmd")
vim.cmd("enew")
vim.cmd("set filetype=markdown")
assert(vim.g.quarto_sync_fixture_setups == 1, "Quarto fixture initialized more than once")
vim.g.nixvim_quarto_test_finished = true

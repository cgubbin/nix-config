vim.g.maplocalleader = ","
package.path = "tests/fixtures/quarto-sync/lua/?.lua;" .. package.path
local sync = dofile("assets/editor/lua/kit/quarto_sync.lua")
local dir = vim.fn.tempname()
vim.fn.mkdir(dir, "p")
local first = dir .. "/first note.qmd"
vim.cmd("edit " .. vim.fn.fnameescape(first))
sync.setup_buffer(vim.api.nvim_get_current_buf())
assert(vim.g.quarto_sync_fixture_setups == 1)
local mapping = vim.fn.maparg(",rp", "n", false, true)
assert(type(mapping.callback) == "function")
mapping.callback()
assert(vim.g.quarto_sync_fixture_preview == dir .. "/copy-of-first note.qmd")
vim.cmd("enew")
sync.setup_buffer(vim.api.nvim_get_current_buf())
assert(vim.g.quarto_sync_fixture_setups == 1)
vim.fn.delete(dir, "rf")

local root = assert(vim.env.NIXVIM_TEST_DIR) .. "/symbol fixture"
vim.fn.mkdir(root, "p")
vim.fn.writefile({ "{}" }, root .. "/.luarc.json")
vim.fn.writefile({ "export SYMBOL_FIXTURE=1" }, root .. "/.envrc")
assert(vim.system({ "direnv", "allow", root }):wait().code == 0)
local path = root .. "/example.lua"
vim.fn.writefile({ "local function fixture_symbol()", "  return 42", "end", "return fixture_symbol()" }, path)
vim.cmd("edit " .. vim.fn.fnameescape(path))
vim.bo.filetype = "lua"
vim.api.nvim_win_set_cursor(0, { 2, 0 })
assert(vim.wait(20000, function() return require("nvim-navic").is_available() end, 50), "Navic did not attach to a language server")
local populated = vim.wait(20000, function()
  vim.api.nvim_exec_autocmds("CursorMoved", { buffer = 0 })
  return require("nvim-navic").get_location():find("fixture_symbol", 1, true) ~= nil
end, 50)
if not populated then
  local response = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", { textDocument = vim.lsp.util.make_text_document_params() }, 3000)
  print("Navic location: " .. vim.inspect(require("nvim-navic").get_location()))
  print("Document symbols: " .. vim.inspect(response))
  error("Navic did not report the current symbol")
end
vim.cmd("AerialOpen")
assert(vim.wait(10000, function() return vim.bo.filetype == "aerial" end, 50), "Aerial outline did not open")

local M = {}
local initialized = false

function M.setup_buffer(buf)
  if not initialized then
    local ok, err = pcall(function() require("quarto-sync").setup({ auto_start = true }) end)
    if not ok then
      vim.notify("Quarto sync setup failed: " .. tostring(err), vim.log.levels.WARN)
      return
    end
    initialized = true
  end
  vim.keymap.set("n", "<localleader>rp", function()
    local name = vim.api.nvim_buf_get_name(buf)
    local dir = vim.fn.fnamemodify(name, ":h")
    local file = vim.fn.fnamemodify(name, ":t")
    vim.cmd("QuartoSyncPreview " .. vim.fn.fnameescape(dir .. "/copy-of-" .. file))
  end, { buffer = buf, desc = "Preview with cell sync" })
end

return M

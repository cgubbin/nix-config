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
  -- Preview the notebook itself: outputs are now saved into it, not into a
  -- sibling copy-of-<name>.ipynb.
  vim.keymap.set("n", "<localleader>rp", function()
    vim.cmd("QuartoSyncPreview " .. vim.fn.fnameescape(vim.api.nvim_buf_get_name(buf)))
  end, { buffer = buf, desc = "Preview with cell sync" })
end

return M

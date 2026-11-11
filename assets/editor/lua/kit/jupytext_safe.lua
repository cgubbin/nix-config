local M = {}

-- jupytext.nvim normally uses a sibling file and may overwrite an unrelated
-- Markdown document. Keep each notebook's scratch file in Neovim's private
-- temporary directory instead; the plugin removes it on buffer unload.
function M.install()
  local files = {}
  local utils = require("jupytext.utils")
  assert(type(utils.get_jupytext_file) == "function", "Unsupported Jupytext version: missing safe conversion hook")
  utils.get_jupytext_file = function(filename, extension)
    local key = vim.fn.resolve(vim.fn.fnamemodify(filename, ":p")) .. "\0" .. extension
    if not files[key] then
      files[key] = vim.fn.tempname() .. "." .. extension
    end
    return files[key]
  end
end

return M

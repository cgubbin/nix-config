local M = {}

local default_notebook = {
  cells = { { cell_type = "markdown", metadata = vim.empty_dict(), source = { "" } } },
  metadata = {
    kernelspec = { display_name = "Python 3", language = "python", name = "python3" },
    language_info = {
      codemirror_mode = { name = "ipython" },
      file_extension = ".py",
      mimetype = "text/x-python",
      name = "python",
      nbconvert_exporter = "python",
      pygments_lexer = "ipython3",
    },
  },
  nbformat = 4,
  nbformat_minor = 5,
}

function M.confirm_replace(path)
  return vim.fn.confirm("Replace existing notebook " .. path .. "?", "&No\n&Yes", 1) == 2
end

function M.create(filename)
  local path = filename .. ".ipynb"
  local uv = vim.uv or vim.loop
  local fd, err = uv.fs_open(path, "wx", 438)
  if not fd and uv.fs_stat(path) then
    if not M.confirm_replace(path) then
      return false
    end
    fd, err = uv.fs_open(path, "w", 438)
  end
  if not fd then
    vim.notify("Could not create notebook: " .. path .. ": " .. tostring(err), vim.log.levels.ERROR)
    return false
  end
  local ok, write_err = uv.fs_write(fd, vim.json.encode(default_notebook) .. "\n", -1)
  uv.fs_close(fd)
  if not ok then
    vim.notify("Could not write notebook: " .. path .. ": " .. tostring(write_err), vim.log.levels.ERROR)
    return false
  end
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  return true
end

return M

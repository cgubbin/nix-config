-- Render the current notebook or document with Quarto into a directory under
-- stdpath("run") and open it, leaving nothing in the repository.
--
-- .py (percent) notebooks are converted to a temporary .ipynb carrying the
-- outputs of the buffer's running kernel, and .ipynb files are copied with
-- their stored outputs: both render what was run, without executing again.
-- .qmd/.md documents execute with the project's Python in their own directory.
-- Quarto comes from the project environment, like other project tools.
local M = {}
local uv = vim.uv or vim.loop

M.dir = vim.fn.stdpath("run") .. "/render"

local function find_executable(name, env)
  for dir in (env.PATH or ""):gmatch("[^:]+") do
    local path = dir .. "/" .. name
    if uv.fs_access(path, "X") then return path end
  end
end

-- Windows browsers launched from WSL cannot open Linux paths directly.
function M.open(path)
  local target = path
  if vim.fn.executable("wslpath") == 1 then
    local converted = vim.fn.system({ "wslpath", "-w", path })
    if vim.v.shell_error == 0 then target = vim.trim(converted) end
  end
  local ok, err = pcall(vim.ui.open, target)
  if not ok then vim.notify("Could not open " .. target .. ": " .. tostring(err), vim.log.levels.ERROR) end
  return target
end

local function fail(msg)
  vim.notify("Notebook render: " .. msg, vim.log.levels.ERROR)
  return msg
end

-- Prepares the file Quarto renders; returns target path and extra arguments.
local function prepare(buf, path, out, stem)
  local ext = path:match("%.([%w]+)$") or ""
  if ext == "ipynb" then
    local target = out .. "/" .. stem .. ".ipynb"
    assert(uv.fs_copyfile(path, target))
    return target, { "--no-execute" }
  end
  if ext == "py" then
    local target = out .. "/" .. stem .. ".ipynb"
    local result = vim.system({ "jupytext", "--to", "ipynb", "--output", target, path }, { text = true }):wait()
    if result.code ~= 0 then return nil, "jupytext failed: " .. vim.trim(result.stderr or "") end
    require("kit.kernel").export(buf, target)
    return target, { "--no-execute" }
  end
  if ext == "qmd" or ext == "md" or ext == "rmd" then
    local target = out .. "/" .. stem .. ".qmd"
    assert(uv.fs_copyfile(path, target))
    return target, { "--execute-dir", vim.fs.dirname(path) }
  end
  return nil, "unsupported file type: ." .. ext
end

function M.render(buf, callback)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  callback = callback or function() end
  local path = vim.api.nvim_buf_get_name(buf)
  if path == "" then return callback(nil, fail("save the buffer first")) end
  if vim.bo[buf].modified then vim.api.nvim_buf_call(buf, function() vim.cmd("silent write") end) end
  path = vim.fn.fnamemodify(path, ":p")
  local stem = vim.fn.fnamemodify(path, ":t:r")
  local out = M.dir .. "/" .. stem .. "-" .. vim.fn.sha256(path):sub(1, 8)
  vim.fn.delete(out, "rf")
  vim.fn.mkdir(out, "p")

  local project = require("kit.project")
  local root = project.root(path)
  vim.notify("Rendering " .. vim.fn.fnamemodify(path, ":~:.") .. " (this takes a while) …")
  project.load_env(root, function(env, env_err)
    if not env then return callback(nil, fail("project environment unavailable: " .. tostring(env_err))) end
    local quarto = find_executable("quarto", env)
    if not quarto then return callback(nil, fail("quarto is not available in the project environment of " .. root)) end
    local target, extra = prepare(buf, path, out, stem)
    if not target then return callback(nil, fail(extra)) end
    local python = require("kit.python").resolve(root, env)
    if python then env.QUARTO_PYTHON = python end
    local args = vim.list_extend({ quarto, "render", target, "--to", "html" }, extra)
    local ok, err = pcall(vim.system, args, { cwd = out, env = env, clear_env = true, text = true }, function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          local stderr = vim.trim(result.stderr or "")
          return callback(nil, fail("quarto exited " .. result.code .. ": " .. (stderr:match("([^\n]*)$") or stderr)))
        end
        local html = out .. "/" .. stem .. ".html"
        if vim.fn.filereadable(html) ~= 1 then return callback(nil, fail("no HTML produced in " .. out)) end
        local opened = M.open(html)
        vim.notify("Rendered; opening " .. opened)
        callback({ html = html, opened = opened })
      end)
    end)
    if not ok then callback(nil, fail("could not start quarto: " .. tostring(err))) end
  end)
end

function M.commands()
  vim.api.nvim_create_user_command("NotebookRender", function() M.render(0) end,
    { desc = "Render this notebook or document to a temporary HTML page and open it" })
end

return M

-- Notebook cells for the editor's run actions.
--
-- Python buffers use Jupytext percent cells (`# %%`): a marker line starts a
-- cell, `# %% [markdown]` cells are not executed, and non-blank text before the
-- first marker is a cell of its own. Markdown and Quarto buffers (including
-- .ipynb files opened through Jupytext) use fenced code chunks (```python,
-- ```{python}); the opening fence plays the marker's role and chunks in other
-- languages are skipped. Every action sends code to the buffer's project kernel
-- through Molten, starting it first (kit.kernel).
local M = {}

local function is_marker(line)
  return line:match("^%s*#%s*%%%%") ~= nil
end

local function is_markdown_marker(line)
  return line:match("^%s*#%s*%%%%.-%[markdown%]") ~= nil or line:match("^%s*#%s*%%%%.-%[md%]") ~= nil
end

local function blank(lines, first, last)
  for i = first, last do
    if lines[i] and lines[i]:match("%S") then return false end
  end
  return true
end

-- Cells as { marker = line or nil, first = line, last = line, markdown = bool }
-- with 1-based content lines excluding the marker. Empty cells have first > last.
function M.parse(lines)
  local cells = {}
  local markers = {}
  for i, line in ipairs(lines) do
    if is_marker(line) then markers[#markers + 1] = i end
  end
  if #markers == 0 then
    if not blank(lines, 1, #lines) then cells[1] = { first = 1, last = #lines, markdown = false } end
    return cells
  end
  if markers[1] > 1 and not blank(lines, 1, markers[1] - 1) then
    cells[#cells + 1] = { first = 1, last = markers[1] - 1, markdown = false }
  end
  for k, m in ipairs(markers) do
    local last = (markers[k + 1] or (#lines + 1)) - 1
    -- Trailing blank lines are separators, not cell content.
    while last > m and not lines[last]:match("%S") do last = last - 1 end
    cells[#cells + 1] = { marker = m, first = m + 1, last = last, markdown = is_markdown_marker(lines[m]) }
  end
  return cells
end

local python_langs = { python = true, python3 = true, py = true, ipython = true }

-- Fenced code chunks: ```lang / ```{lang ...} to the closing ```. Prose between
-- chunks is not a cell. An unclosed chunk runs to the end of the buffer.
function M.parse_fenced(lines)
  local cells = {}
  local open
  for i, line in ipairs(lines) do
    if open then
      if line:match("^%s*```+%s*$") then
        open.last = i - 1
        cells[#cells + 1] = open
        open = nil
      end
    else
      local lang = line:match("^%s*```+%s*{?%s*([%w_]*)")
      if lang then
        open = { marker = i, first = i + 1, last = i, markdown = not python_langs[lang:lower()] }
      end
    end
  end
  if open then
    open.last = #lines
    cells[#cells + 1] = open
  end
  return cells
end

-- Index of the cell containing line (a marker belongs to the cell it starts).
function M.index(cells, line)
  local found
  for i, cell in ipairs(cells) do
    local start = cell.marker or cell.first
    if line >= start then found = i else break end
  end
  return found
end

local function runnable(cell)
  return not cell.markdown and cell.first <= cell.last
end

local function percent(buf)
  return vim.bo[buf].filetype == "python"
end

function M.cells(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  return percent(buf) and M.parse(lines) or M.parse_fenced(lines)
end

local function kernel_name(buf, info)
  if info and info.name then return info.name end
  local ok, kernels = pcall(vim.api.nvim_buf_call, buf, function() return vim.fn.MoltenRunningKernels(true) end)
  return ok and kernels[1] or nil
end

local function evaluate(buf, info, ranges)
  local name = kernel_name(buf, info)
  if not name then return vim.notify("No notebook kernel attached", vim.log.levels.ERROR) end
  if #ranges == 0 then return vim.notify("No code cell here") end
  vim.api.nvim_buf_call(buf, function()
    for _, r in ipairs(ranges) do
      vim.fn.MoltenEvaluateRange(name, r[1], r[2])
    end
  end)
end

local function with_kernel(buf, fn)
  require("kit.kernel").ensure(buf, function(info) fn(info) end)
end

local function resolve(buf)
  return (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
end

-- First content line of the cell after the one containing line.
local function next_line(cells, line)
  local nxt = cells[(M.index(cells, line) or 0) + 1]
  if not nxt then return nil end
  return nxt.first <= nxt.last and nxt.first or (nxt.marker or nxt.first)
end

function M.run_cell(buf, advance)
  buf = resolve(buf)
  local win = vim.api.nvim_get_current_win()
  local line = vim.api.nvim_win_get_cursor(win)[1]
  with_kernel(buf, function(info)
    local cells = M.cells(buf)
    local cell = cells[M.index(cells, line) or 0]
    if cell and runnable(cell) then evaluate(buf, info, { { cell.first, cell.last } }) end
    if advance and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
      local target = next_line(cells, line)
      if target then vim.api.nvim_win_set_cursor(win, { math.min(target, vim.api.nvim_buf_line_count(buf)), 0 }) end
    end
  end)
end

function M.run_above(buf)
  buf = resolve(buf)
  local line = vim.api.nvim_win_get_cursor(0)[1]
  with_kernel(buf, function(info)
    local cells = M.cells(buf)
    local ranges = {}
    for i = 1, (M.index(cells, line) or 0) do
      if runnable(cells[i]) then ranges[#ranges + 1] = { cells[i].first, cells[i].last } end
    end
    evaluate(buf, info, ranges)
  end)
end

function M.run_all(buf)
  buf = resolve(buf)
  with_kernel(buf, function(info)
    local ranges = {}
    for _, cell in ipairs(M.cells(buf)) do
      if runnable(cell) then ranges[#ranges + 1] = { cell.first, cell.last } end
    end
    evaluate(buf, info, ranges)
  end)
end

function M.run_line(buf)
  buf = resolve(buf)
  local line = vim.api.nvim_win_get_cursor(0)[1]
  with_kernel(buf, function(info) evaluate(buf, info, { { line, line } }) end)
end

function M.run_range(buf, first, last)
  buf = resolve(buf)
  with_kernel(buf, function(info) evaluate(buf, info, { { first, last } }) end)
end

-- Moves the cursor to the next (count > 0) or previous cell.
function M.jump(buf, count)
  buf = resolve(buf)
  local cells = M.cells(buf)
  if #cells == 0 then return vim.notify("No cells in this buffer") end
  local i = M.index(cells, vim.api.nvim_win_get_cursor(0)[1]) or 0
  local target = cells[math.max(1, math.min(#cells, i + count))]
  vim.api.nvim_win_set_cursor(0, { target.marker or target.first, 0 })
end

return M

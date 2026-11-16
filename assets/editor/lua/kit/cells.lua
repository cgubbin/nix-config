-- Notebook cells for the editor's run actions.
--
-- Python buffers use Jupytext percent cells (`# %%`): a marker line starts a
-- cell, `# %% [markdown]` cells are not executed, and non-blank text before the
-- first marker is a cell of its own. Other notebook buffers (Quarto, Markdown
-- from Jupytext) keep quarto-nvim's runner. Every action makes sure the buffer
-- has its project kernel first (kit.kernel).
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

local function buffer_cells(buf)
  return M.parse(vim.api.nvim_buf_get_lines(buf, 0, -1, false))
end

local function kernel_name(buf, info)
  if info and info.name then return info.name end
  local ok, kernels = pcall(vim.api.nvim_buf_call, buf, function() return vim.fn.MoltenRunningKernels(true) end)
  return ok and kernels[1] or nil
end

local function evaluate(buf, info, ranges)
  local name = kernel_name(buf, info)
  if not name then return vim.notify("No notebook kernel attached", vim.log.levels.ERROR) end
  vim.api.nvim_buf_call(buf, function()
    for _, r in ipairs(ranges) do
      vim.fn.MoltenEvaluateRange(name, r[1], r[2])
    end
  end)
end

local function with_kernel(buf, fn)
  require("kit.kernel").ensure(buf, function(info) fn(info) end)
end

local function percent(buf)
  return vim.bo[buf].filetype == "python"
end

local function quarto_runner()
  return require("quarto.runner")
end

-- Next cell start (percent) or next fenced code chunk (Quarto/Markdown).
local function next_line(buf, line)
  if percent(buf) then
    local cells = buffer_cells(buf)
    local i = M.index(cells, line)
    local nxt = cells[(i or 0) + 1]
    return nxt and (nxt.first <= nxt.last and nxt.first or (nxt.marker or nxt.first)) or nil
  end
  -- First line inside the next ```{lang} chunk below the cursor.
  local lines = vim.api.nvim_buf_get_lines(buf, line, -1, false)
  for offset, text in ipairs(lines) do
    if text:match("^%s*```%s*{") then return line + offset + 1 end
  end
  return nil
end

function M.run_cell(buf, advance)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local win = vim.api.nvim_get_current_win()
  local line = vim.api.nvim_win_get_cursor(win)[1]
  with_kernel(buf, function(info)
    if percent(buf) then
      local cells = buffer_cells(buf)
      local cell = cells[M.index(cells, line) or 0]
      if cell and runnable(cell) then evaluate(buf, info, { { cell.first, cell.last } }) end
    else
      quarto_runner().run_cell()
    end
    if advance and vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
      local target = next_line(buf, line)
      if target then vim.api.nvim_win_set_cursor(win, { math.min(target, vim.api.nvim_buf_line_count(buf)), 0 }) end
    end
  end)
end

function M.run_above(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local line = vim.api.nvim_win_get_cursor(0)[1]
  with_kernel(buf, function(info)
    if not percent(buf) then return quarto_runner().run_above() end
    local cells = buffer_cells(buf)
    local ranges = {}
    for i = 1, (M.index(cells, line) or 0) do
      if runnable(cells[i]) then ranges[#ranges + 1] = { cells[i].first, cells[i].last } end
    end
    evaluate(buf, info, ranges)
  end)
end

function M.run_all(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  with_kernel(buf, function(info)
    if not percent(buf) then return quarto_runner().run_all() end
    local ranges = {}
    for _, cell in ipairs(buffer_cells(buf)) do
      if runnable(cell) then ranges[#ranges + 1] = { cell.first, cell.last } end
    end
    evaluate(buf, info, ranges)
  end)
end

function M.run_line(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local line = vim.api.nvim_win_get_cursor(0)[1]
  with_kernel(buf, function(info)
    if not percent(buf) then return quarto_runner().run_line() end
    evaluate(buf, info, { { line, line } })
  end)
end

function M.run_range(buf, first, last)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  with_kernel(buf, function(info)
    if not percent(buf) then return quarto_runner().run_range() end
    evaluate(buf, info, { { first, last } })
  end)
end

-- Moves the cursor to the next (count > 0) or previous cell.
function M.jump(buf, count)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local cells = buffer_cells(buf)
  local i = M.index(cells, vim.api.nvim_win_get_cursor(0)[1]) or 0
  local target = cells[math.max(1, math.min(#cells, i + count))]
  if target then vim.api.nvim_win_set_cursor(0, { target.marker or target.first, 0 }) end
end

return M

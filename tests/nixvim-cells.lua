-- Percent-format cell parsing and run actions.
local cells = require("kit.cells")

local function same(actual, expected, what)
  assert(vim.deep_equal(actual, expected), what .. ": " .. vim.inspect(actual))
end

-- No markers: the whole non-blank buffer is one cell; blank buffer has none.
same(cells.parse({ "x = 1", "y = 2" }), { { first = 1, last = 2, markdown = false } }, "no markers")
same(cells.parse({ "", "  " }), {}, "blank buffer")

-- Header before the first marker, markdown cells, trailing blank lines, empty last cell.
local lines = {
  "import sys",            -- 1 header cell
  "",                      -- 2
  "# %%",                  -- 3
  "a = 1",                 -- 4
  "",                      -- 5
  "# %% [markdown]",       -- 6
  "# Some prose",          -- 7
  "#%% second code",       -- 8 (no space after #)
  "b = 2",                 -- 9
  "c = 3",                 -- 10
  "",                      -- 11
  "# %%",                  -- 12 empty last cell
}
local parsed = cells.parse(lines)
same(parsed, {
  { first = 1, last = 2, markdown = false },
  { marker = 3, first = 4, last = 4, markdown = false },
  { marker = 6, first = 7, last = 7, markdown = true },
  { marker = 8, first = 9, last = 10, markdown = false },
  { marker = 12, first = 13, last = 12, markdown = false },
}, "mixed cells")

-- A marker line belongs to the cell it starts; header lines to the header cell.
assert(cells.index(parsed, 1) == 1 and cells.index(parsed, 3) == 2 and cells.index(parsed, 5) == 2)
assert(cells.index(parsed, 6) == 3 and cells.index(parsed, 11) == 4 and cells.index(parsed, 12) == 5)
-- Marker on line 1: no header cell.
same(cells.parse({ "# %%", "x" }), { { marker = 1, first = 2, last = 2, markdown = false } }, "marker first")

-- Run actions send the right ranges to the buffer's kernel, starting it first.
local kernel = require("kit.kernel")
local ensure = kernel.ensure
local evaluate = vim.fn.MoltenEvaluateRange
local calls, ensured = {}, 0
kernel.ensure = function(_, fn) ensured = ensured + 1; fn({ name = "fake-kernel" }) end
vim.fn.MoltenEvaluateRange = function(name, first, last) calls[#calls + 1] = { name, first, last } end

vim.cmd("enew")
vim.bo.filetype = "python"
vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

-- Python buffers get exactly the hot-path keys; the rest lives in the Hydra.
local function mapped(mode, lhs)
  return vim.fn.maparg(lhs:gsub("<localleader>", vim.g.maplocalleader), mode, false, true).buffer == 1
end
assert(mapped("n", "<localleader>rc") and mapped("n", "<localleader>mI") and mapped("v", "<localleader>r"), "notebook keys missing")
for _, removed in ipairs({ "<localleader>ra", "<localleader>mi", "<localleader>qp", "<localleader>me" }) do
  assert(not mapped("n", removed), removed .. " should now be in the Hydra only")
end

vim.api.nvim_win_set_cursor(0, { 4, 0 })
cells.run_cell(0, true)
same(calls, { { "fake-kernel", 4, 4 } }, "run cell")
assert(vim.api.nvim_win_get_cursor(0)[1] == 7, "advance should land on the next cell, got line " .. vim.api.nvim_win_get_cursor(0)[1])

calls = {}
cells.run_cell(0, true) -- markdown cell: nothing runs, cursor still advances
same(calls, {}, "markdown cell")
assert(vim.api.nvim_win_get_cursor(0)[1] == 9)

calls = {}
cells.run_above(0)
same(calls, { { "fake-kernel", 1, 2 }, { "fake-kernel", 4, 4 }, { "fake-kernel", 9, 10 } }, "run above")

calls = {}
cells.run_all(0)
same(calls, { { "fake-kernel", 1, 2 }, { "fake-kernel", 4, 4 }, { "fake-kernel", 9, 10 } }, "run all")
assert(ensured == 4, "every action must ensure a kernel, got " .. ensured)

vim.api.nvim_win_set_cursor(0, { 9, 0 })
cells.jump(0, 1)
assert(vim.api.nvim_win_get_cursor(0)[1] == 12)
cells.jump(0, -2)
assert(vim.api.nvim_win_get_cursor(0)[1] == 6)

-- The Hydra's heads are functions, not strings fed as keys: `<localleader>j`
-- then `c` runs the current cell, `n` jumps, `q` exits.
calls = {}
vim.api.nvim_win_set_cursor(0, { 4, 0 })
local lines_before = vim.api.nvim_buf_get_lines(0, 0, -1, false)
vim.api.nvim_feedkeys(vim.g.maplocalleader .. "jcnq", "xt", false)
same(calls, { { "fake-kernel", 4, 4 } }, "Hydra c head")
assert(vim.api.nvim_win_get_cursor(0)[1] == 6, "Hydra n head should jump to line 6, got " .. vim.api.nvim_win_get_cursor(0)[1])
same(vim.api.nvim_buf_get_lines(0, 0, -1, false), lines_before, "Hydra heads must not type into the buffer")

kernel.ensure = ensure
vim.fn.MoltenEvaluateRange = evaluate
vim.cmd("bwipeout!")

-- Saving a percent-format notebook writes only that file: no paired .ipynb.
local dir = assert(vim.env.NIXVIM_TEST_DIR) .. "/percent-save"
vim.fn.mkdir(dir, "p")
vim.cmd("edit " .. vim.fn.fnameescape(dir .. "/analysis.py"))
vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
vim.bo.undofile = false -- undodir is the fixture consumer's home, absent in the sandbox
vim.cmd("write")
local files = vim.fn.readdir(dir)
same(files, { "analysis.py" }, "files after saving a percent notebook")
vim.cmd("bwipeout!")

-- Fenced chunks (Markdown/Quarto, and .ipynb opened through Jupytext).
local md = {
  "# Title",                -- 1
  "",                       -- 2
  "```python",              -- 3 Jupytext style
  "a = 1",                  -- 4
  "```",                    -- 5
  "Some prose.",            -- 6
  "```{python}",            -- 7 Quarto style
  "#| echo: false",         -- 8
  "b = 2",                  -- 9
  "```",                    -- 10
  "```{r}",                 -- 11 other language: skipped
  "x <- 1",                 -- 12
  "```",                    -- 13
  "```python",              -- 14 unclosed
  "c = 3",                  -- 15
}
same(cells.parse_fenced(md), {
  { marker = 3, first = 4, last = 4, markdown = false },
  { marker = 7, first = 8, last = 9, markdown = false },
  { marker = 11, first = 12, last = 12, markdown = true },
  { marker = 14, first = 15, last = 15, markdown = false },
}, "fenced chunks")
same(cells.parse_fenced({ "just prose", "" }), {}, "prose only")

kernel.ensure = function(_, fn) fn({ name = "fake-kernel" }) end
vim.fn.MoltenEvaluateRange = function(name, first, last) calls[#calls + 1] = { name, first, last } end
vim.cmd("enew")
vim.bo.filetype = "markdown"
vim.api.nvim_buf_set_lines(0, 0, -1, false, md)
calls = {}
vim.api.nvim_win_set_cursor(0, { 4, 0 })
cells.run_cell(0, true)
same(calls, { { "fake-kernel", 4, 4 } }, "markdown run cell")
assert(vim.api.nvim_win_get_cursor(0)[1] == 8, "advance in markdown, got " .. vim.api.nvim_win_get_cursor(0)[1])
calls = {}
cells.run_all(0)
same(calls, { { "fake-kernel", 4, 4 }, { "fake-kernel", 8, 9 }, { "fake-kernel", 15, 15 } }, "markdown run all")
vim.api.nvim_win_set_cursor(0, { 1, 0 })
cells.jump(0, 1)
assert(vim.api.nvim_win_get_cursor(0)[1] == 3, "jump from prose to first chunk, got " .. vim.api.nvim_win_get_cursor(0)[1])
-- The Hydra works the same way in Markdown buffers.
calls = {}
vim.api.nvim_win_set_cursor(0, { 9, 0 })
vim.api.nvim_feedkeys(vim.g.maplocalleader .. "jcq", "xt", false)
same(calls, { { "fake-kernel", 8, 9 } }, "Hydra c head in markdown")
kernel.ensure = ensure
vim.fn.MoltenEvaluateRange = evaluate
vim.cmd("bwipeout!")

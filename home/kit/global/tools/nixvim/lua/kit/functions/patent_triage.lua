local M = {}

local function current_path()
    return vim.api.nvim_buf_get_name(0)
end

local function is_inbox(path)
    return path:match("/98_INBOX/") ~= nil
end

local function move_file(src, dst)
    local ok, err = os.rename(src, dst)
    if not ok then
        vim.notify("Move failed: " .. err, vim.log.levels.ERROR)
        return false
    end
    return true
end

local function update_frontmatter_field(lines, key, value)
    for i, line in ipairs(lines) do
        if line:match("^" .. key .. ":") then
            lines[i] = key .. ": " .. value
            return lines
        end
    end
    return lines
end

local function write_buffer(lines)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.cmd("write")
end

-- -------------------------
-- Promote patent
-- -------------------------

function M.promote()
    local path = current_path()

    if not is_inbox(path) then
        vim.notify("Not in inbox", vim.log.levels.WARN)
        return
    end

    local filename = vim.fn.fnamemodify(path, ":t")
    local vault = vim.fn.getcwd()
    local target = vault .. "/01_Patents/" .. filename

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    lines = update_frontmatter_field(lines, "source", "hybrid")
    lines = update_frontmatter_field(lines, "review_status", "partial")

    write_buffer(lines)

    if move_file(path, target) then
        vim.cmd("edit " .. target)
        vim.notify("Promoted → 01_Patents", vim.log.levels.INFO)
    end
end

-- -------------------------
-- Mark skip
-- -------------------------

function M.mark_skip()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    lines = update_frontmatter_field(lines, "importance", "1")
    lines = update_frontmatter_field(lines, "review_status", "skipped")

    write_buffer(lines)
    vim.notify("Marked SKIP", vim.log.levels.INFO)
end

-- -------------------------
-- Mark keep
-- -------------------------

function M.mark_keep()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

    lines = update_frontmatter_field(lines, "importance", "4")
    lines = update_frontmatter_field(lines, "review_status", "interesting")

    write_buffer(lines)
    vim.notify("Marked KEEP", vim.log.levels.INFO)
end

-- -------------------------
-- Next inbox file
-- -------------------------

function M.next_inbox()
    local current = current_path()
    local dir = vim.fn.getcwd() .. "/98_INBOX"

    local files = vim.fn.globpath(dir, "*.md", false, true)
    table.sort(files)

    for i, f in ipairs(files) do
        if f == current and files[i + 1] then
            vim.cmd("edit " .. files[i + 1])
            return
        end
    end

    vim.notify("No next inbox file", vim.log.levels.INFO)
end

return M

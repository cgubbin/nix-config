local M = {}

local function cursor()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    return row, col
end

local function line_to_cursor()
    local row, col = cursor()
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
    return line:sub(1, col)
end


local function not_postfix_context(line_to_cursor, matched_trigger)
    matched_trigger = matched_trigger or ""
    return not (
        line_to_cursor:match("%.$") or
        line_to_cursor:match("%." .. matched_trigger .. "$")
    )
end

local function count_unescaped(text, pat)
    local count = 0
    local i = 1
    while true do
        local s, e = text:find(pat, i)
        if not s then break end
        local bs = 0
        local j = s - 1
        while j >= 1 and text:sub(j, j) == "\\" do
            bs = bs + 1
            j = j - 1
        end
        if bs % 2 == 0 then
            count = count + 1
        end
        i = e + 1
    end
    return count
end

local function in_md_inline_dollar()
    local text = line_to_cursor()
    local singles = 0
    local i = 1
    while i <= #text do
        local a = text:sub(i, i)
        local b = text:sub(i + 1, i + 1)
        if a == "\\" then
            i = i + 2
        elseif a == "$" and b == "$" then
            i = i + 2
        elseif a == "$" then
            singles = singles + 1
            i = i + 1
        else
            i = i + 1
        end
    end
    return singles % 2 == 1
end

local function in_md_inline_paren()
    local text = line_to_cursor()
    return count_unescaped(text, "\\%(") > count_unescaped(text, "\\%)")
end

local function in_md_display_bracket()
    local row = cursor()
    local lines = vim.api.nvim_buf_get_lines(0, 0, row, false)
    local joined = table.concat(lines, "\n")
    return count_unescaped(joined, "\\%[") > count_unescaped(joined, "\\%]")
end

local function in_md_display_dollar()
    local row = cursor()
    local lines = vim.api.nvim_buf_get_lines(0, 0, row, false)
    local toggles = 0
    for _, line in ipairs(lines) do
        if line:match("^%s*%$%$%s*$") then
            toggles = toggles + 1
        end
    end
    return toggles % 2 == 1
end

local function is_markdown_ft()
    local ft = vim.bo.filetype
    return ft == "markdown" or ft == "md" or ft == "rmd" or ft == "quarto"
end


local function loc_in_markdown_math()
    if not is_markdown_ft() then
        return false
    end

    return in_md_inline_dollar()
        or in_md_inline_paren()
        or in_md_display_dollar()
        or in_md_display_bracket()
end

local M = {}

function M.show_line_begin()
    return #line_to_cursor() <= 3
end

function M.in_markdown_math()
    return loc_in_markdown_math()
end

function M.in_md_display_math()
    if not is_markdown_ft() then
        return false
    end

    return in_md_display_dollar() or in_md_display_bracket()
end

function M.md_math_not_postfix(line_to_cursor, matched_trigger)
    error("DEBUG: [" .. tostring(line_to_cursor) .. "] [" .. tostring(matched_trigger) .. "]")
    return loc_in_markdown_math() and not_postfix_context(line_to_cursor, matched_trigger)
end

return M

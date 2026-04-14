local M = {}

local uv = vim.uv or vim.loop

local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = "patents" })
end

local function current_file()
    return vim.api.nvim_buf_get_name(0)
end

local function is_markdown()
    return vim.bo.filetype == "markdown" or current_file():match("%.md$") ~= nil
end

local function buf_lines()
    return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

local function trim(s)
    return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function file_exists(path)
    return path and path ~= "" and uv.fs_stat(path) ~= nil
end

local function dirname(path)
    return vim.fn.fnamemodify(path, ":h")
end

local function basename_no_ext(path)
    return vim.fn.fnamemodify(path, ":t:r")
end

local function ensure_dir(path)
    if vim.fn.isdirectory(path) == 0 then
        vim.fn.mkdir(path, "p")
    end
end

local function inside_obsidian(path)
    return path:find("/obsidian/", 1, true) ~= nil
end

local function vault_root(path)
    path = path or current_file()
    local dir = dirname(path)
    local markers = {
        "00_System", "01_Patents", "02_Concepts", "03_Components", "04_Signals", "05_Techniques", "06_Analysis",
        "07_Queries", "08_Review", "09_Dashboards", "10_PDFs", "98_INBOX",
    }
    local cur = dir
    while cur and cur ~= "/" and cur ~= "" do
        for _, m in ipairs(markers) do
            if vim.fn.isdirectory(cur .. "/" .. m) == 1 then
                return cur
            end
        end
        local parent = vim.fn.fnamemodify(cur, ":h")
        if parent == cur then break end
        cur = parent
    end
    return vim.fn.getcwd()
end

local function parse_scalar(v)
    v = trim(v)
    if v == "true" then return true end
    if v == "false" then return false end
    if v == "[]" then return {} end
    if tonumber(v) ~= nil then return tonumber(v) end
    if (v:sub(1, 1) == '"' and v:sub(-1) == '"') or (v:sub(1, 1) == "'" and v:sub(-1) == "'") then
        return v:sub(2, -2)
    end
    return v
end

local function parse_frontmatter(lines)
    if not lines or #lines == 0 or lines[1] ~= "---" then return nil end
    local fm = {}
    local i = 2
    local current_key = nil
    while i <= #lines do
        local line = lines[i]
        if line == "---" then
            break
        end
        local key, rest = line:match("^([%w_]+):%s*(.*)$")
        if key then
            if rest == "" then
                fm[key] = {}
                current_key = key
            else
                fm[key] = parse_scalar(rest)
                current_key = nil
            end
        else
            local item = line:match("^%s*%-%s*(.+)$")
            if item and current_key then
                if type(fm[current_key]) ~= "table" then fm[current_key] = {} end
                table.insert(fm[current_key], parse_scalar(item))
            end
        end
        i = i + 1
    end
    fm._frontmatter_end = i
    return fm
end

local function yaml_value(v)
    if type(v) == "boolean" then
        return v and "true" or "false"
    elseif type(v) == "number" then
        return tostring(v)
    elseif type(v) == "table" then
        if vim.tbl_isempty(v) then return "[]" end
        return nil
    elseif v == nil then
        return ""
    else
        return tostring(v)
    end
end

local canonical_order = {
    "type", "id", "title",
    "source", "confidence", "review_status", "importance",
    "primary_source", "patent_url", "pdf_path", "pdf_url",
    "modality", "signal_type", "contrast_mechanism",
    "has_new_signal", "has_new_geometry", "has_new_processing", "ml_component",
}

local defaults = {
    type = "patent",
    id = "",
    title = "",
    source = "model",
    confidence = "low",
    review_status = "unreviewed",
    importance = 3,
    primary_source = "patent_url",
    patent_url = "",
    pdf_path = "",
    pdf_url = "",
    modality = "unknown",
    signal_type = {},
    contrast_mechanism = {},
    has_new_signal = false,
    has_new_geometry = false,
    has_new_processing = false,
    ml_component = false,
}

local function looks_like_patent_filename(path)
    local name = vim.fn.fnamemodify(path, ":t:r")
    return name:match("^US%d+$")
        or name:match("^EP%d+[A-Z]%d*$")
        or name:match("^WO%d+$")
        or name:match("^[A-Z][A-Z]%d+[A-Z0-9]*$")
end

local function in_patents_folder(path)
    return path:match("(^|/)01_Patents/") ~= nil
end

local function looks_like_patent_note(fm, path)
    if not path or path == "" then
        return false
    end

    if not is_markdown() then
        return false
    end

    if fm and fm.type == "patent" then
        return true
    end

    if in_patents_folder(path) then
        return true
    end

    if looks_like_patent_filename(path) then
        return true
    end

    return false
end

local function get_frontmatter()
    return parse_frontmatter(buf_lines())
end

local function validate_frontmatter(fm, path)
    local errors, warnings = {}, {}
    path = path or current_file()
    local function err(x) table.insert(errors, x) end
    local function warn(x) table.insert(warnings, x) end

    for _, k in ipairs({ "type", "id", "source", "confidence", "review_status" }) do
        if fm[k] == nil or fm[k] == "" then err("Missing required field: " .. k) end
    end
    if fm.type and fm.type ~= "patent" then err("type must be 'patent'") end
    if not ((fm.patent_url and fm.patent_url ~= "") or (fm.pdf_path and fm.pdf_path ~= "") or (fm.pdf_url and fm.pdf_url ~= "")) then
        err("At least one of patent_url, pdf_path, or pdf_url must be set")
    end
    if fm.signal_type ~= nil and type(fm.signal_type) ~= "table" then err("signal_type must be a YAML list") end
    if fm.contrast_mechanism ~= nil and type(fm.contrast_mechanism) ~= "table" then
        err(
            "contrast_mechanism must be a YAML list")
    end
    local fname = basename_no_ext(path)
    if fm.id and fm.id ~= "" and fname ~= fm.id then
        warn("Filename ('" .. fname .. "') does not match id ('" .. fm.id .. "')")
    end
    if fm.pdf_path and fm.pdf_path ~= "" and fm.id and fm.id ~= "" then
        local expected = "10_PDFs/" .. fm.id .. ".pdf"
        if fm.pdf_path ~= expected then
            warn("pdf_path differs from convention; expected " .. expected)
        end
    end
    return errors, warnings
end

function M.validate_patent_note()
    local path = current_file()
    if not is_markdown() then
        notify("Not a markdown buffer", vim.log.levels.WARN)
        return false
    end
    local fm = get_frontmatter()
    if not fm then
        notify("Missing YAML frontmatter", vim.log.levels.ERROR)
        return false
    end
    if not looks_like_patent_note(fm, path) then
        notify("Current note is not a patent note", vim.log.levels.WARN)
        return true
    end
    local errors, warnings = validate_frontmatter(fm, path)
    if #warnings > 0 then
        notify(table.concat(warnings, "\n"), vim.log.levels.WARN)
    end
    if #errors > 0 then
        notify(table.concat(errors, "\n"), vim.log.levels.ERROR)
        return false
    end
    notify("Patent note validated", vim.log.levels.INFO)
    return true
end

function M.validate_current_on_save()
    local path = current_file()
    if path == "" or not is_markdown() then
        return true
    end

    if not in_patents_folder(path) then
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local fm = parse_frontmatter(lines)
        if not (fm and fm.type == "patent") then
            return true
        end
    end

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local fm = parse_frontmatter(lines)

    if not fm then
        vim.notify("Patent note is missing YAML frontmatter", vim.log.levels.ERROR)
        return false
    end

    local errors, warnings = validate_frontmatter(fm, path)

    if #warnings > 0 then
        vim.notify(table.concat(warnings, "\n"), vim.log.levels.WARN)
    end

    if #errors > 0 then
        vim.notify(table.concat(errors, "\n"), vim.log.levels.ERROR)
        return false
    end

    return true
end

function M.normalize_frontmatter()
    local lines = buf_lines()
    local fm = parse_frontmatter(lines)
    if not fm then
        notify("No YAML frontmatter found", vim.log.levels.WARN)
        return
    end
    if not looks_like_patent_note(fm, current_file()) then
        notify("Current note is not a patent note", vim.log.levels.WARN)
        return
    end
    for k, v in pairs(defaults) do
        if fm[k] == nil then fm[k] = v end
    end
    local out = { "---" }
    for _, k in ipairs(canonical_order) do
        local v = fm[k]
        if type(v) == "table" then
            if vim.tbl_isempty(v) then
                table.insert(out, k .. ": []")
            else
                table.insert(out, k .. ":")
                for _, item in ipairs(v) do
                    table.insert(out, "  - " .. tostring(item))
                end
            end
        else
            table.insert(out, k .. ": " .. yaml_value(v))
        end
    end
    -- preserve unknown keys after canonical keys
    for k, v in pairs(fm) do
        if k ~= "_frontmatter_end" and not vim.tbl_contains(canonical_order, k) then
            if type(v) == "table" then
                if vim.tbl_isempty(v) then
                    table.insert(out, k .. ": []")
                else
                    table.insert(out, k .. ":")
                    for _, item in ipairs(v) do
                        table.insert(out, "  - " .. tostring(item))
                    end
                end
            else
                table.insert(out, k .. ": " .. yaml_value(v))
            end
        end
    end
    table.insert(out, "---")

    local body_start = (fm._frontmatter_end or 1) + 1
    local body = {}
    for i = body_start, #lines do table.insert(body, lines[i]) end
    for _, line in ipairs(body) do table.insert(out, line) end
    vim.api.nvim_buf_set_lines(0, 0, -1, false, out)
    notify("Patent frontmatter normalized")
end

function M.suggest_patent_pdf_path()
    local fm = get_frontmatter()
    local id = (fm and fm.id and fm.id ~= "") and fm.id or basename_no_ext(current_file())
    local suggestion = "10_PDFs/" .. id .. ".pdf"
    vim.fn.setreg('"', suggestion)
    notify("Copied suggested pdf_path: " .. suggestion)
end

local function open_target(cmd)
    vim.fn.jobstart(cmd, { detach = true })
end

function M.open_patent_pdf()
    local fm = get_frontmatter()
    if not fm then
        notify("Missing YAML frontmatter", vim.log.levels.ERROR)
        return
    end
    local root = vault_root()
    if fm.pdf_path and fm.pdf_path ~= "" then
        local target = fm.pdf_path
        if not target:match("^/") then target = root .. "/" .. target end
        open_target({ "zathura", target })
        return
    end
    if fm.pdf_url and fm.pdf_url ~= "" then
        open_target({ "xdg-open", fm.pdf_url })
        return
    end
    notify("No pdf_path or pdf_url found", vim.log.levels.ERROR)
end

function M.open_patent_source()
    local fm = get_frontmatter()
    if not fm then
        notify("Missing YAML frontmatter", vim.log.levels.ERROR)
        return
    end
    if fm.pdf_path and fm.pdf_path ~= "" then
        return M.open_patent_pdf()
    end
    if fm.pdf_url and fm.pdf_url ~= "" then
        open_target({ "xdg-open", fm.pdf_url })
        return
    end
    if fm.patent_url and fm.patent_url ~= "" then
        open_target({ "xdg-open", fm.patent_url })
        return
    end
    notify("No patent source found", vim.log.levels.ERROR)
end

local function slugify(s)
    s = trim(s)
    s = s:gsub("%[%[", ""):gsub("%]%]", "")
    s = s:lower():gsub("[^%w%s_-]", ""):gsub("%s+", "_")
    s = s:gsub("_+", "_")
    return s
end

local folder_map = {
    concept = "02_Concepts",
    component = "03_Components",
    signal = "04_Signals",
    technique = "05_Techniques",
    analysis = "06_Analysis",
    query = "07_Queries",
}

local function get_visual_selection()
    local mode = vim.fn.mode()
    if mode ~= "v" and mode ~= "V" then return nil end
    local _, ls, cs = unpack(vim.fn.getpos("'<"))
    local _, le, ce = unpack(vim.fn.getpos("'>"))
    if ls ~= le then return nil end
    local line = vim.api.nvim_buf_get_lines(0, ls - 1, ls, false)[1]
    return line:sub(cs, ce)
end

local function insert_text(text)
    vim.api.nvim_put({ text }, "c", true, true)
end

function M.insert_wikilink()
    local text = get_visual_selection() or vim.fn.expand("<cword>")
    text = slugify(text)
    if text == "" then
        text = slugify(vim.fn.input("Link target: "))
    end
    if text == "" then return end
    insert_text("[[" .. text .. "]]")
end

function M.insert_or_create_wikilink()
    local text = get_visual_selection() or vim.fn.expand("<cword>")
    text = slugify(text)
    if text == "" then
        text = slugify(vim.fn.input("Link target: "))
    end
    if text == "" then return end
    local kind = vim.fn.input("Kind (concept/component/signal/technique/analysis/query) [concept]: ")
    if kind == "" then kind = "concept" end
    local folder = folder_map[kind]
    if not folder then
        notify("Unknown kind: " .. kind, vim.log.levels.ERROR)
        return
    end
    local root = vault_root()
    local path = root .. "/" .. folder .. "/" .. text .. ".md"
    if not file_exists(path) then
        ensure_dir(dirname(path))
        local title = text:gsub("_", " "):gsub("%f[%a].", string.upper)
        local contents = {
            "---",
            "type: " .. kind,
            "---",
            "",
            "# " .. title,
            "",
        }
        vim.fn.writefile(contents, path)
    end
    insert_text("[[" .. text .. "]]")
end

local function telescope_grep(prompt_title, pattern)
    local ok, builtin = pcall(require, "telescope.builtin")
    if ok then
        builtin.live_grep({ default_text = pattern, prompt_title = prompt_title })
    else
        vim.cmd("vimgrep /" .. vim.fn.escape(pattern, "/") .. "/gj **/*.md")
        vim.cmd("copen")
    end
end

function M.search_missing()
    telescope_grep("Patent Search Missing", "MISSING")
end

function M.search_novelty()
    telescope_grep("Patent Search Novelty", "Actually novel:")
end

function M.search_open_questions()
    telescope_grep("Patent Search Open Questions", "Open Questions")
end

function M.review_search()
    local root = vault_root()
    local target = root .. "/01_Patents"

    local lines = vim.fn.systemlist({
        "rg",
        "--vimgrep",
        "-e", "review_status:\\s*unreviewed",
        "-e", "confidence:\\s*low",
        target,
    })

    vim.fn.setqflist({}, "r", {
        title = "Patent review search",
        lines = lines,
    })

    vim.cmd("copen")
end

function M.next_missing()
    vim.fn.search("MISSING", "W")
end

function M.next_section_gap()
    vim.fn.search("^##\\s\\+", "W")
end

function M.register_autocmds()
    local group = vim.api.nvim_create_augroup("PatentWorkflow", { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        pattern = "*.md",
        callback = function()
            local ok = M.validate_current_on_save()
            if ok == false then
                error("Patent validation failed")
            end
        end,
    })
end

return M

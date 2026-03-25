-- [
-- snip_env + autosnippets
-- ]
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local types = require("luasnip.util.types")
local parse = require("luasnip.util.parser").parse_snippet
local ms = ls.multi_snippet
local autosnippet = ls.extend_decorator.apply(s, { snippetType = "autosnippet" })

-- [
-- personal imports
-- ]
package.path = vim.fn.stdpath("config") .. "/LuaSnip/markdown/?.lua;" .. package.path
local md = require("utils.conditions")
local line_begin = require("luasnip.extras.conditions.expand").line_begin

local mconds = require("luasnip.extras.conditions")
local md_math = mconds.make_condition(function()
    return md.in_markdown_math()
end)

-- Generating functions for Matrix/Cases - thanks L3MON4D3!
local generate_matrix = function(args, snip)
    local rows = tonumber(snip.captures[2])
    local cols = tonumber(snip.captures[3])
    local nodes = {}
    local ins_indx = 1
    for j = 1, rows do
        table.insert(nodes, r(ins_indx, tostring(j) .. "x1", i(1)))
        ins_indx = ins_indx + 1
        for k = 2, cols do
            table.insert(nodes, t(" & "))
            table.insert(nodes, r(ins_indx, tostring(j) .. "x" .. tostring(k), i(1)))
            ins_indx = ins_indx + 1
        end
        table.insert(nodes, t({ "\\\\", "" }))
    end
    -- fix last node.
    nodes[#nodes] = t("\\\\")
    return sn(nil, nodes)
end

-- update for cases
local generate_cases = function(args, snip)
    local rows = tonumber(snip.captures[1]) or 2 -- default option 2 for cases
    local cols = 2                               -- fix to 2 cols
    local nodes = {}
    local ins_indx = 1
    for j = 1, rows do
        table.insert(nodes, r(ins_indx, tostring(j) .. "x1", i(1)))
        ins_indx = ins_indx + 1
        for k = 2, cols do
            table.insert(nodes, t(" & "))
            table.insert(nodes, r(ins_indx, tostring(j) .. "x" .. tostring(k), i(1)))
            ins_indx = ins_indx + 1
        end
        table.insert(nodes, t({ "\\\\", "" }))
    end
    -- fix last node.
    table.remove(nodes, #nodes)
    return sn(nil, nodes)
end

M = {
    -- Inline math
    autosnippet({ trig = "mk", name = "$..$", dscr = "inline math" },
        fmta([[$<>$<>]], {
            i(1),
            i(0),
        })
    ),

    -- Display math
    autosnippet({ trig = "dm", name = "$$..$$", dscr = "display math" },
        fmta([[
$$
<>
$$
<>]], {
            i(1),
            i(0),
        }),
        { condition = md.show_line_begin, show_condition = md.show_line_begin }
    ),

    -- Aligned block (Markdown-safe equivalent of align)
    autosnippet({ trig = "ali", name = "aligned", dscr = "aligned math" },
        fmta([[
$$
\begin{aligned}
<>
\end{aligned}
$$
<>]], {
            i(1),
            i(0),
        }),
        { condition = md.show_line_begin, show_condition = md.show_line_begin }
    ),

    -- &= line, only inside display math
    autosnippet({ trig = "==", name = "&= align", dscr = "&= align" },
        fmta([[
&<> <> \\
]], {
            c(1, { t("="), t([[\leq]]), i(1) }),
            i(2),
        }),
        { condition = md.in_md_display_math, show_condition = md.in_md_display_math }
    ),

    -- Gathered block
    autosnippet({ trig = "gat", name = "gathered", dscr = "gathered math" },
        fmta([[
$$
\begin{gathered}
<>
\end{gathered}
$$
<>]], {
            i(1),
            i(0),
        }),
        { condition = md.show_line_begin, show_condition = md.show_line_begin }
    ),

    -- Equation block equivalent
    autosnippet({ trig = "eqn", name = "$$ equation $$", dscr = "equation math" },
        fmta([[
$$
<>
$$
<>]], {
            i(1),
            i(0),
        }),
        { condition = md.show_line_begin, show_condition = md.show_line_begin }
    ),

    -- Matrices
    s(
        { trig = "([bBpvV])mat(%d+)x(%d+)([ar])", name = "[bBpvV]matrix", dscr = "matrices", regTrig = true, hidden = true },
        fmta([[
\begin{<>}<>
<>
\end{<>}]], {
            f(function(_, snip)
                return snip.captures[1] .. "matrix"
            end),
            f(function(_, snip)
                if snip.captures[4] == "a" then
                    local out = string.rep("c", tonumber(snip.captures[3]) - 1)
                    return "[" .. out .. "|c]"
                end
                return ""
            end),
            d(1, generate_matrix),
            f(function(_, snip)
                return snip.captures[1] .. "matrix"
            end),
        }),
        { condition = md.in_markdown_math, show_condition = md.in_markdown_math }
    ),

    -- Cases
    autosnippet({ trig = "(%d?)cases", name = "cases", dscr = "cases", regTrig = true, hidden = true },
        fmta([[
\begin{cases}
<>
\end{cases}
]], {
            d(1, generate_cases),
        }),
        { condition = md.in_markdown_math, show_condition = md.in_markdown_math }
    ),
    postfix(
        {
            trig = ".sci",
            name = "scientific notation",
            dscr = "x × 10^{y}",
            snippetType = "autosnippet",
            match_pattern = "([%+%-]?%d*%.?%d+)$",
        },
        {
            d(1, function(_, parent)
                local x = parent.snippet.env.POSTFIX_MATCH
                return sn(nil, {
                    t(x .. " \\times 10^{"),
                    i(1),
                    t("}"),
                    i(0),
                })
            end),
        }
    )

};

return M

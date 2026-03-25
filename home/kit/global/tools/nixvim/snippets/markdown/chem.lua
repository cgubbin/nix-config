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
local expand_conds = require("luasnip.extras.conditions.expand")

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

local chem_match = "([%a%d%^_%+%-%(%)]+)$"

M = {
    -- Chem modes
    autosnippet({ trig = "ce", name = "ce{}", dscr = "species with concentration" },
        fmta([[\ce{<>}<>]],
            { i(1), i(0) }),
        {
            condition = md_math * expand_conds.trigger_not_preceded_by("%."),
            show_condition = md_math,
        }),
    autosnippet({ trig = "cnc", name = "[concentration]", dscr = "species with concentration" },
        fmta([[\left[\ce{<>}\right]<>]],
            { i(1), i(0) }),
        {
            condition = md_math * expand_conds.trigger_not_preceded_by("%."),
            show_condition = md_math,
        }),
    autosnippet({ trig = "cre", name = "[chemical equilibrium]", dscr = "Chemical equilibrium reaction" },
        fmt([[\ce{{{} <=> {}}}{}]], {
            i(1, "H2O(l)"),
            i(2, "H+ + OH-"),
            i(0),
        }),
        {
            condition = md_math * expand_conds.trigger_not_preceded_by("%."),
            show_condition = md_math,
        }),
    autosnippet({ trig = "crr", name = "[chemical reaction]", dscr = "Chemical reaction" },
        fmt([[\ce{{{} -> {}}}{}]], {
            i(1),
            i(2),
            i(0),
        }),
        {
            condition = md_math * expand_conds.trigger_not_preceded_by("%."),
            show_condition = md_math,
        }),
    autosnippet(
        { trig = "car", name = "chem arrow with condition" },
        fmt([[\ce{{{} ->[{}] {}}}{}]], {
            i(1),
            i(2, "\\Delta"),
            i(3),
            i(0),
        }),
        {
            condition = md_math * expand_conds.trigger_not_preceded_by("%."),
            show_condition = md_math,
        }),
    autosnippet(
        { trig = "acid", name = "acid dissociation" },
        fmt([[\ce{{{} <=> H+ + {}}}{}]], {
            i(1, "HA"),
            i(2, "A-"),
            i(0),
        }),
        { condition = md_math, show_condition = md_math }),
    autosnippet(
        { trig = "base", name = "base hydrolysis" },
        fmt([[\ce{{{} + H2O <=> {} + OH-}}{}]], {
            i(1, "B"),
            i(2, "BH+"),
            i(0),
        }),
        { condition = md_math, show_condition = md_math }),
    autosnippet(
        { trig = "kc", name = "Kc expression" },
        fmta([[
K_c = \frac{<>}{<>}<>
]], {
            i(1, [[\left[\ce{C}\right]^c \left[\ce{D}\right]^d]]),
            i(2, [[\left[\ce{A}\right]^a \left[\ce{B}\right]^b]]),
            i(0),
        }),
        { condition = md_math, show_condition = md_math }),
    autosnippet({ trig = "ph", name = "pH" }, t("pH"),
        { condition = md_math, show_condition = md_math }),
    autosnippet({ trig = "pka", name = "pKa" }, t("pK_a"),
        { condition = md_math, show_condition = md_math }),
    autosnippet({ trig = "pkb", name = "pKb" }, t("pK_b"),
        { condition = md_math, show_condition = md_math }),
    postfix(
        {
            trig = ".ce",
            name = "\\ce{}",
            dscr = "wrap species in \\ce{}",
            snippetType = "autosnippet",
            match_pattern = chem_match
        },
        f(function(_, parent)
            local m = parent.snippet.env.POSTFIX_MATCH
            return "\\ce{" .. m .. "}"
        end),
        { condition = md_math }
    ),

    postfix(
        {
            trig = ".cnc",
            name = "[concentration]",
            dscr = "wrap species in [\\ce{}]",
            snippetType = "autosnippet",
            match_pattern = chem_match
        },
        f(function(_, parent)
            local m = parent.snippet.env.POSTFIX_MATCH
            return "\\left[\\ce{" .. m .. "}\\right]"
        end),
        { condition = md_math }
    ),

    postfix(
        {
            trig = ".cre",
            name = "equilibrium reaction",
            dscr = "wrap lhs in equilibrium reaction",
            snippetType = "autosnippet",
            match_pattern = chem_match
        },
        d(1, function(_, parent)
            local m = parent.snippet.env.POSTFIX_MATCH
            return sn(nil, {
                t("\\ce{" .. m .. " <=> "),
                i(1),
                t("}"),
            })
        end),
        { condition = md_math }
    ),

    postfix(
        {
            trig = ".crr",
            name = "reaction arrow",
            dscr = "wrap lhs in reaction arrow",
            snippetType = "autosnippet",
            match_pattern = chem_match
        },
        d(1, function(_, parent)
            local m = parent.snippet.env.POSTFIX_MATCH
            return sn(nil, {
                t("\\ce{" .. m .. " -> "),
                i(1),
                t("}"),
            })
        end),
        { condition = md_math }
    ),
    postfix(
        {
            trig = ".car",
            name = "reaction with condition",
            dscr = "wrap lhs in reaction with condition",
            snippetType = "autosnippet",
            match_pattern = chem_match
        },
        d(1, function(_, parent)
            local m = parent.snippet.env.POSTFIX_MATCH
            return sn(nil, {
                t("\\ce{" .. m .. " ->["),
                i(1, "\\Delta"),
                t("] "),
                i(2),
                t("}"),
            })
        end),
        { condition = md_math }
    ),
}

return M

local seen = {}
-- Query visual and select separately: querying the combined "v" mode can
-- return the same key once for each of those distinct modes.
for _, mode in ipairs({ "n", "i", "x", "s", "o", "t", "c" }) do
  for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
    local key = mode .. "\0" .. map.lhs
    assert(not seen[key], "duplicate mapping: " .. mode .. " " .. map.lhs)
    seen[key] = true
  end
end
for _, lhs in ipairs({ "<leader>hp", "<leader>hP", "<leader>tn", "<leader>td" }) do
  assert(vim.fn.maparg(lhs, "n") ~= "", "missing expected mapping: " .. lhs)
end

seen = {}
for _, autocmd in ipairs(vim.api.nvim_get_autocmds({})) do
  local key = table.concat({
    autocmd.event or "", tostring(autocmd.group or ""), autocmd.pattern or "",
    autocmd.command or "", tostring(autocmd.callback or ""), autocmd.desc or "",
  }, "\0")
  assert(not seen[key], "duplicate autocmd: " .. autocmd.event .. " " .. (autocmd.pattern or ""))
  seen[key] = true
end

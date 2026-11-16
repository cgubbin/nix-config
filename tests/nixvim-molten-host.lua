-- Molten loads as a remote plugin without PYTHONPATH changes, and Neovim does
-- not pass an empty PYTHONPATH entry (the current directory) to child Pythons.
local pythonpath = vim.env.PYTHONPATH or ""
for entry in (pythonpath .. ":"):gmatch("(.-):") do
  if pythonpath ~= "" then
    assert(entry ~= "", "PYTHONPATH has an empty entry: " .. vim.inspect(pythonpath))
  end
  assert(not entry:match("molten%-nvim"), "PYTHONPATH still carries Molten's rplugin path: " .. pythonpath)
end

assert(vim.fn.exists(":MoltenInit") == 2, "MoltenInit is not registered")
local ok, kernels = pcall(vim.fn.MoltenAvailableKernels)
assert(ok, "MoltenAvailableKernels failed: " .. tostring(kernels))
assert(type(kernels) == "table", "MoltenAvailableKernels returned " .. vim.inspect(kernels))

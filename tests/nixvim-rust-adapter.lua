local base = assert(vim.env.NIXVIM_TEST_DIR)
local root = base .. "/rust project;touch INJECTION_MARKER;"
local source = root .. "/src/lib.rs"
local cargo = vim.fn.exepath("cargo")
assert(cargo ~= "", "cargo is required")
vim.fn.mkdir(root .. "/src", "p")
vim.fn.mkdir(root .. "/bin", "p")
vim.fn.writefile({ '[package]', 'name = "project_test"', 'version = "0.1.0"', 'edition = "2021"' }, root .. "/Cargo.toml")
local marker = root .. "/test-ran"
vim.fn.writefile({
  '#[cfg(test)]',
  'mod tests {',
  '  #[test]',
  '  fn project_test() {',
  '    assert_eq!(std::env::var("NIXVIM_RUST_PROJECT").unwrap(), "approved");',
  '    std::fs::write(std::env::var("NIXVIM_RUST_MARKER").unwrap(), "passed").unwrap();',
  '}',
  '}',
}, source)
vim.fn.writefile({ "PATH_add bin", "export NIXVIM_RUST_PROJECT=approved", "export NIXVIM_RUST_MARKER=" .. vim.fn.shellescape(marker) }, root .. "/.envrc")
vim.fn.writefile({
  "#!/bin/sh",
  'test "$NIXVIM_RUST_PROJECT" = approved || exit 97',
  "exec " .. vim.fn.shellescape(cargo) .. ' "$@"',
}, root .. "/bin/cargo")
assert((vim.uv or vim.loop).fs_chmod(root .. "/bin/cargo", 493))
assert(vim.system({ "direnv", "allow", root }, { text = true }):wait().code == 0)
vim.fn.chdir(base)
local adapter = require("neotest-rust")
assert(adapter.root(source) == root, "Rust metadata did not use the approved environment")
local build = vim.system({ "direnv", "exec", root, "cargo", "test", "--no-run", "--offline" }, {
  cwd = root, text = true,
}):wait()
assert(build.code == 0, "Rust test setup failed: " .. (build.stderr or "") .. (build.stdout or ""))
local binary = require("neotest-rust.dap").get_test_binary(root, source)
assert(binary and vim.fn.executable(binary) == 1, "Rust test binary not built")
vim.fn.chdir(root)
vim.cmd("edit " .. vim.fn.fnameescape(source))
require("neotest").run.run(source)
local done = vim.wait(30000, function() return vim.fn.filereadable(marker) == 1 end, 50)
if not done then
  print("Neotest adapter IDs: " .. vim.inspect(require("neotest").state.adapter_ids()))
  for _, id in ipairs(require("neotest").state.adapter_ids()) do
    local tree = require("neotest").state.positions({ adapter = id })
    print("Neotest tree " .. id .. ": " .. vim.inspect(tree and tree:to_list() or nil))
  end
  for _, path in ipairs(vim.fn.glob(vim.fn.stdpath("state") .. "/**/*neotest*", true, true)) do
    if vim.fn.filereadable(path) == 1 then print(table.concat(vim.fn.readfile(path), "\n")) end
  end
  error("Rust Neotest did not run the project test")
end
assert(vim.fn.filereadable(base .. "/INJECTION_MARKER") == 0, "project path was interpreted by a shell")

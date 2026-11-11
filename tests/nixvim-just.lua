local base = assert(vim.env.NIXVIM_TEST_DIR)
local just = require("kit.just")
local function project(name, recipe)
  local root = base .. "/just " .. name
  vim.fn.mkdir(root, "p")
  vim.fn.writefile({ "export PROJECT_NAME=" .. name }, root .. "/.envrc")
  vim.fn.writefile({ recipe .. " arg:", '    printf "%s:%s" "$PROJECT_NAME" "{{arg}}" > result' }, root .. "/justfile")
  assert(vim.system({ "direnv", "allow", root }):wait().code == 0)
  return root
end
local a = project("A", "alpha")
local b = project("B", "beta")
local function discover(root)
  local done, recipes, err = false
  just.discover(root, root .. "/justfile", function(r, e) recipes, err, done = r, e, true end)
  assert(vim.wait(10000, function() return done end), "discovery timed out")
  return recipes, err
end
local ar = assert(discover(a))
local br = assert(discover(b))
assert(#ar == 1 and ar[1].name == "alpha")
assert(#br == 1 and br[1].name == "beta")
assert(vim.fn.filereadable(a .. "/result") == 0, "discovery ran a recipe")
local task = just.run(a, a .. "/justfile", "alpha", { "hello world" })
assert(vim.wait(10000, function() return task:is_complete() end))
assert(task.status == "SUCCESS" and vim.fn.readfile(a .. "/result")[1] == "A:hello world")
vim.fn.writefile({ "not a valid justfile !!!" }, b .. "/justfile")
local recipes, err = discover(b)
assert(not recipes and err:find("Just discovery failed"))
local original_path = vim.env.PATH
local justless = base .. "/justless"
vim.fn.mkdir(justless, "p")
assert((vim.uv or vim.loop).fs_symlink(vim.fn.exepath("direnv"), justless .. "/direnv"))
vim.env.PATH = justless
recipes, err = discover(a)
vim.env.PATH = original_path
assert(not recipes and err:find("Just discovery failed"), "missing Just should report an error")
vim.fn.writefile({ "many *args:", '    printf "%s\\n" {{args}} > picked' }, a .. "/justfile")
vim.cmd("edit " .. vim.fn.fnameescape(a .. "/source.py"))
local select, input = vim.ui.select, vim.ui.input
local answers = { "first", "second", "" }
vim.ui.select = function(items, _, callback) callback(items[1]) end
vim.ui.input = function(_, callback) callback(table.remove(answers, 1)) end
just.pick()
assert(vim.wait(10000, function()
  return vim.fn.filereadable(a .. "/picked") == 1 and #vim.fn.readfile(a .. "/picked") == 2
end), "picker did not run recipe")
vim.ui.select, vim.ui.input = select, input
assert(vim.deep_equal(vim.fn.readfile(a .. "/picked"), { "first", "second" }))
vim.fn.writefile({ "mod child" }, b .. "/justfile")
vim.fn.writefile({ "nested:", '    printf nested > nested-result' }, b .. "/child.just")
local nested = assert(discover(b))
assert(#nested == 1 and nested[1].name == "child::nested", "Just module recipe was not discovered")
local nested_task = just.run(b, b .. "/justfile", nested[1].name, {})
assert(vim.wait(10000, function() return nested_task:is_complete() end) and nested_task.status == "SUCCESS")

local noxroot = base .. "/just nox"
vim.fn.mkdir(noxroot, "p")
vim.fn.writefile({}, noxroot .. "/requirements.lock")
vim.fn.writefile({
  "import nox",
  "@nox.session",
  "def tests(session):",
  "    session.install('--no-index', '-r', 'requirements.lock')",
  "    session.run('python', '-c', \"import sys; assert sys.prefix != sys.base_prefix; print('isolated-nox-ok')\")",
}, noxroot .. "/noxfile.py")
vim.fn.writefile({ "test:", "    nox -s tests" }, noxroot .. "/justfile")
local nox_task = just.run(noxroot, noxroot .. "/justfile", "test", {})
assert(vim.wait(30000, function() return nox_task:is_complete() end, 50), "Nox task timed out")
local nox_output = table.concat(vim.api.nvim_buf_get_lines(nox_task:get_bufnr(), 0, -1, false), "\n")
assert(nox_task.status == "SUCCESS", "Just/Nox task failed: " .. nox_output)
assert(nox_output:find("isolated%-nox%-ok"), "Nox session output missing")

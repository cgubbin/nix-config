local dir = assert(vim.env.NIXVIM_TEST_DIR)
local a = dir .. "/environment-a"
local b = dir .. "/environment-b"
local blocked = dir .. "/environment-blocked"
for _, root in ipairs({ a, b, blocked }) do vim.fn.mkdir(root, "p") end
vim.fn.writefile({ "export NIXVIM_PROJECT=A", "unset NIXVIM_REMOVE" }, a .. "/.envrc")
vim.fn.writefile({ "export NIXVIM_PROJECT=B", "export NIXVIM_REMOVE=from-b" }, b .. "/.envrc")
vim.fn.writefile({ "export NIXVIM_PROJECT=allowed" }, blocked .. "/.envrc")
for _, root in ipairs({ a, b }) do
  assert(vim.system({ "direnv", "allow", root }, { text = true }):wait().code == 0)
end
vim.env.NIXVIM_REMOVE = "base"
local project_env = dofile((vim.env.NIXVIM_EDITOR_ASSETS or "assets/editor") .. "/lua/kit/project_env.lua")
local function load(root)
  local done, env, err = false, nil, nil
  project_env.load(root, function(value, message) env, err, done = value, message, true end)
  assert(vim.wait(10000, function() return done end, 10), "direnv did not finish")
  return env, err
end
local first, err = load(a)
assert(first, err)
local second; second, err = load(b)
assert(second, err)
local again; again, err = load(a)
assert(again, err)
for _, item in ipairs({ { first, "A:unset" }, { second, "B:from-b" }, { again, "A:unset" } }) do
  local result = vim.system({ "sh", "-c", 'printf "%s:%s" "$NIXVIM_PROJECT" "${NIXVIM_REMOVE-unset}"' }, {
    env = item[1], clear_env = true, text = true,
  }):wait()
  assert(result.code == 0 and result.stdout == item[2], vim.inspect(result))
end
local denied, message = load(blocked)
assert(not denied and message, "unapproved direnv should fail")
assert(vim.system({ "direnv", "allow", blocked }, { text = true }):wait().code == 0)
local retried; retried, err = load(blocked)
assert(retried and retried.NIXVIM_PROJECT == "allowed", err)
vim.fn.writefile({ "export NIXVIM_PROJECT=changed-after-approval" }, a .. "/.envrc")
local changed, changed_err = load(a)
assert(not changed and changed_err, "changed environment should not use a stale cache")
assert(vim.system({ "direnv", "allow", a }, { text = true }):wait().code == 0)
changed, err = load(a)
assert(changed and changed.NIXVIM_PROJECT == "changed-after-approval", err)
assert(vim.env.NIXVIM_REMOVE == "base" and not vim.env.NIXVIM_PROJECT)

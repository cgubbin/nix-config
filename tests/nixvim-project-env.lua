vim.env.NIXVIM_TEST_REMOVED = "base"
local env = dofile((vim.env.NIXVIM_EDITOR_ASSETS or "assets/editor") .. "/lua/kit/project_env.lua")
local original_system = vim.system
local requests = {}
vim.system = function(command, options, callback)
  assert(command[1] == "direnv" and options.clear_env)
  requests[#requests + 1] = { callback = callback, options = options }
end

local function finish(index, result)
  requests[index].callback(result)
  assert(vim.wait(1000, function() return requests[index].done end))
end
local function load(root)
  local result = {}
  env.load(root, function(value, err)
    result.value, result.err = value, err
    result.done = true
    if result.request then requests[result.request].done = true end
  end)
  result.request = #requests
  return result
end

local a = load("/a")
finish(a.request, { code = 0, stdout = '{"NIXVIM_TEST_PROJECT":"a","NIXVIM_TEST_REMOVED":null}' })
assert(a.value.NIXVIM_TEST_PROJECT == "a" and a.value.NIXVIM_TEST_REMOVED == nil)
local b = load("/b")
finish(b.request, { code = 0, stdout = '{"NIXVIM_TEST_PROJECT":"b"}' })
assert(b.value.NIXVIM_TEST_PROJECT == "b" and b.value.NIXVIM_TEST_REMOVED == "base")
local again = load("/a")
assert(again.done and again.value.NIXVIM_TEST_PROJECT == "a")
assert(vim.env.NIXVIM_TEST_PROJECT == nil and vim.env.NIXVIM_TEST_REMOVED == "base")
for _, item in ipairs({ { a.value, "a", "unset" }, { b.value, "b", "base" }, { again.value, "a", "unset" } }) do
  local result = original_system({ "sh", "-c", 'printf "%s:%s" "$NIXVIM_TEST_PROJECT" "${NIXVIM_TEST_REMOVED-unset}"' }, {
    env = item[1], clear_env = true, text = true,
  }):wait()
  assert(result.code == 0 and result.stdout == item[2] .. ":" .. item[3])
end

env.invalidate("/a")
local stale = load("/a")
env.invalidate("/a")
local current = load("/a")
finish(current.request, { code = 0, stdout = '{"NIXVIM_TEST_PROJECT":"new"}' })
finish(stale.request, { code = 0, stdout = '{"NIXVIM_TEST_PROJECT":"stale"}' })
assert(stale.err and current.value.NIXVIM_TEST_PROJECT == "new")

local failed = load("/failed")
finish(failed.request, { code = 1, stderr = "not allowed" })
assert(failed.err and not failed.value)
local retry = load("/failed")
finish(retry.request, { code = 0, stdout = "{}" })
assert(retry.value and not retry.err)
local concurrent = load("/concurrent")
local same = load("/concurrent")
assert(concurrent.request == same.request, "concurrent loads should share one request")
finish(concurrent.request, { code = 0, stdout = '{"NIXVIM_TEST_PROJECT":"shared"}' })
assert(same.done and same.value.NIXVIM_TEST_PROJECT == "shared")
vim.system = original_system

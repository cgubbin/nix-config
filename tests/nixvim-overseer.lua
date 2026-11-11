local overseer = require("overseer")
local messages = {}
local original_notify = vim.notify
vim.notify = function(message) messages[#messages + 1] = message end
local restart = vim.fn.maparg(vim.g.mapleader .. "Ol", "n", false, true)
assert(type(restart.callback) == "function", "restart mapping missing")
restart.callback()
assert(messages[1] == "No task to restart", "missing empty task diagnostic")
vim.notify = original_notify
local task = overseer.new_task({
  cmd = { "sh", "-c", "printf overseer-ok" },
  components = { "on_exit_set_status" },
})
task:start()
assert(vim.wait(5000, function() return task:is_complete() end, 20), "task did not finish")
assert(task.status == "SUCCESS", "task failed: " .. tostring(task.status))
local lines = vim.api.nvim_buf_get_lines(task:get_bufnr(), 0, -1, false)
assert(table.concat(lines, "\n"):find("overseer%-ok"), "task output missing")
local failed = overseer.new_task({
  cmd = { "sh", "-c", "exit 7" },
  components = { "on_exit_set_status" },
})
failed:start()
assert(vim.wait(5000, function() return failed:is_complete() end, 20), "failed task did not finish")
assert(failed.status == "FAILURE", "failed task was not reported")

local M = {}

function M.find(path)
  local found = vim.fs.find({ "justfile", "Justfile", ".justfile", ".Justfile" }, { upward = true, path = path })[1]
  if not found then return nil, "No justfile found for this buffer" end
  return vim.fs.dirname(found), found
end

function M.discover(root, file, callback)
  if vim.fn.executable("direnv") ~= 1 then return callback(nil, "direnv is not available") end
  vim.system({ "direnv", "exec", root, "just", "--justfile", file, "--dump", "--dump-format", "json" },
    { cwd = root, text = true, timeout = 10000 }, function(result)
      vim.schedule(function()
        if result.code ~= 0 then return callback(nil, "Just discovery failed: " .. (result.stderr or "")) end
        local ok, data = pcall(vim.json.decode, result.stdout or "")
        if not ok or type(data) ~= "table" or type(data.recipes) ~= "table" then
          return callback(nil, "Just returned invalid recipe information")
        end
        local recipes = {}
        local function collect(module)
          for _, recipe in pairs(module.recipes or {}) do
            if not recipe.private then
              recipe.name = recipe.namepath or recipe.name
              recipes[#recipes + 1] = recipe
            end
          end
          for _, child in pairs(module.modules or {}) do collect(child) end
        end
        collect(data)
        table.sort(recipes, function(a, b) return a.name < b.name end)
        callback(recipes)
      end)
    end)
end

function M.run(root, file, recipe, args)
  local command = { "direnv", "exec", root, "just", "--justfile", file, "--working-directory", root, recipe }
  vim.list_extend(command, args or {})
  local task = require("overseer").new_task({ cmd = command, cwd = root, name = "Just: " .. recipe })
  task:start()
  return task
end

function M.pick()
  local file = vim.api.nvim_buf_get_name(0)
  local start = file ~= "" and vim.fs.dirname(file) or vim.fn.getcwd()
  local root, path = M.find(start)
  if not root then return vim.notify(path, vim.log.levels.ERROR) end
  M.discover(root, path, function(recipes, err)
    if not recipes then return vim.notify(err, vim.log.levels.ERROR) end
    vim.ui.select(recipes, { prompt = "Just recipe (" .. root .. ")", format_item = function(item)
      return item.name .. (item.doc and " — " .. item.doc or "")
    end }, function(recipe)
      if not recipe then return end
      local args = {}
      local variadic_count = 0
      local function prompt(index)
        local parameter = (recipe.parameters or {})[index]
        if not parameter then M.run(root, path, recipe.name, args); return end
        local variadic = parameter.kind == "star" or parameter.kind == "plus"
        vim.ui.input({ prompt = "Argument " .. parameter.name .. (variadic and " (blank to finish): " or ": ") }, function(value)
          if value == nil then return end
          if variadic then
            if value ~= "" then args[#args + 1] = value; variadic_count = variadic_count + 1; prompt(index); return end
            if parameter.kind == "plus" and variadic_count == 0 then
              return vim.notify("At least one argument is required for " .. parameter.name, vim.log.levels.ERROR)
            end
          elseif value ~= "" or parameter.default == nil or parameter.default == vim.NIL then
            args[#args + 1] = value
          end
          prompt(index + 1)
        end)
      end
      prompt(1)
    end)
  end)
end

return M

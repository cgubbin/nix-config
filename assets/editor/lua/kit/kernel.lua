-- Notebook kernels run in the project's selected Python environment.
--
-- Kernelspecs are generated into a directory under stdpath("run") that is put
-- on JUPYTER_PATH before Molten's Python host starts. Nothing is written to the
-- project or to the user's Jupyter data directory. Each spec runs the
-- environment's interpreter directly with the project environment captured by
-- kit.project (direnv plus the selected venv or Pixi activation), so starting a
-- kernel never re-runs direnv or project shell hooks.
local M = {}
local uv = vim.uv or vim.loop

M.dir = vim.fn.stdpath("run") .. "/jupyter"
M.check_timeout = 20000

-- Must run before Molten's remote-plugin host starts: the host reads
-- JUPYTER_PATH once, while jupyter_client rescans the directory on each lookup.
function M.setup()
  vim.fn.mkdir(M.dir .. "/kernels", "p")
  local existing = vim.env.JUPYTER_PATH
  if not (existing or ""):find(M.dir, 1, true) then
    vim.env.JUPYTER_PATH = M.dir .. ((existing and existing ~= "") and (":" .. existing) or "")
  end
  -- jupyter_client writes connection files here and fails if it is missing
  -- (the default under the user's data directory may not exist yet).
  if not vim.env.JUPYTER_RUNTIME_DIR or vim.env.JUPYTER_RUNTIME_DIR == "" then
    vim.env.JUPYTER_RUNTIME_DIR = M.dir .. "/runtime"
  end
  vim.fn.mkdir(vim.env.JUPYTER_RUNTIME_DIR, "p", tonumber("700", 8))
  -- Molten also writes a copy of each connection file to a hard-coded
  -- "<jupyter data dir>/runtime/" and fails if that directory does not exist.
  vim.fn.mkdir(M.data_dir() .. "/runtime", "p", tonumber("700", 8))
end

-- jupyter_core's data directory on Linux.
function M.data_dir()
  if vim.env.JUPYTER_DATA_DIR and vim.env.JUPYTER_DATA_DIR ~= "" then return vim.env.JUPYTER_DATA_DIR end
  local xdg = vim.env.XDG_DATA_HOME
  if not xdg or xdg == "" then xdg = vim.fn.expand("~/.local/share") end
  return xdg .. "/jupyter"
end

function M.name(root, python)
  local base = vim.fs.basename(root):lower():gsub("[^%w]+", "-"):gsub("^%-+", ""):gsub("%-+$", "")
  if base == "" then base = "project" end
  return base .. "-" .. vim.fn.sha256(root .. "\0" .. python):sub(1, 10)
end

-- Several Pixi environments and no explicit selection is ambiguous. A uv .venv
-- or a single Pixi environment is not; Nox environments are test sessions, not
-- notebook targets, so they never make a project ambiguous.
function M.ambiguous(root)
  if require("kit.python_env").get(root) then return false end
  local pixi = 0
  for _, choice in ipairs(require("kit.python_env").choices(root)) do
    if choice.kind == "pixi" then pixi = pixi + 1 end
  end
  return pixi > 1
end

local function preparation_hint(root, python)
  if python:find("/%.pixi/envs/") then return "pixi add ipykernel" end
  if uv.fs_stat(root .. "/uv.lock") or python:find("/%.venv/") then return "uv add --dev ipykernel" end
  return "install ipykernel into " .. python
end

-- Confirms the interpreter can start a kernel. Importing ipykernel.kernelapp
-- also imports pyzmq, so missing native libraries surface here, not at start.
function M.check(root, python, env, callback)
  local ok, err = pcall(vim.system, { python, "-c", "import ipykernel.kernelapp" },
    { cwd = root, env = env, clear_env = true, text = true, timeout = M.check_timeout }, function(out)
      vim.schedule(function()
        if out.code == 0 then return callback(true) end
        local stderr = vim.trim(out.stderr or "")
        local last = stderr:match("([^\n]*)$") or stderr
        if last:find("No module named 'ipykernel'", 1, true) then
          return callback(false, "ipykernel is not installed in " .. python .. "; run `" .. preparation_hint(root, python) .. "` in " .. root)
        end
        callback(false, "Kernel cannot start from " .. python .. ": " .. (last ~= "" and last or ("exit " .. tostring(out.code))))
      end)
    end)
  if not ok then callback(false, "Could not run " .. python .. ": " .. tostring(err)) end
end

local function write_json(path, value)
  local tmp = path .. ".tmp"
  local fd = assert(uv.fs_open(tmp, "w", 420))
  assert(uv.fs_write(fd, vim.json.encode(value)))
  assert(uv.fs_close(fd))
  assert(uv.fs_rename(tmp, path))
end

function M.write(root, python, env, label)
  local name = M.name(root, python)
  local dir = M.dir .. "/kernels/" .. name
  vim.fn.mkdir(dir, "p")
  write_json(dir .. "/kernel.json", {
    argv = { python, "-m", "ipykernel_launcher", "-f", "{connection_file}" },
    display_name = vim.fs.basename(root) .. " (" .. label .. ")",
    language = "python",
    env = env,
    metadata = { debugger = true, kit = { root = root, python = python } },
  })
  return name
end

-- callback(info) with info = { name, python, root, label } or callback(nil, err)
function M.prepare(root, callback)
  local project = require("kit.project")
  if M.ambiguous(root) then
    return callback(nil, "Several Pixi environments in " .. root .. "; choose one with :NotebookKernelSelect")
  end
  project.load_env(root, function(env, err)
    if not env then return callback(nil, "Project environment unavailable: " .. tostring(err)) end
    local python, why = require("kit.python").resolve(root, env)
    if not python then return callback(nil, why) end
    M.check(root, python, env, function(ok, check_err)
      if not ok then return callback(nil, check_err) end
      local choice = require("kit.python_env").get(root)
      local label = choice and choice.label or (python:find("/%.pixi/envs/") and "Pixi" or "automatic")
      local name = M.write(root, python, env, label)
      callback({ name = name, python = python, root = root, label = label })
    end)
  end)
end

local function contains(list, value)
  for _, item in ipairs(list or {}) do
    if item == value then return true end
  end
  return false
end

local function attached(buf)
  local ok, kernels = pcall(vim.api.nvim_buf_call, buf, function() return vim.fn.MoltenRunningKernels(true) end)
  return ok and kernels or {}
end

-- Starts (or shares) the project kernel for buf. callback(info) or callback(nil, err).
function M.start(buf, callback)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  callback = callback or function() end
  local root = require("kit.project").root(vim.api.nvim_buf_get_name(buf))
  -- Loading the project environment can take a while (project hooks), so say
  -- something now rather than after it finishes.
  vim.notify("Starting notebook kernel for " .. vim.fn.fnamemodify(root, ":~") .. " …")
  M.prepare(root, function(info, err)
    if not info then
      vim.notify("Notebook kernel: " .. err, vim.log.levels.ERROR)
      return callback(nil, err)
    end
    if not vim.api.nvim_buf_is_valid(buf) then return callback(nil, "buffer closed") end
    local running = vim.fn.MoltenRunningKernels(false)
    local shared = contains(running, info.name)

    -- Report the kernel only once Molten has seen it ready. Molten's readiness
    -- check (jupyter_client's wait_for_ready) flushes the kernel's IOPub
    -- channel, so the output of a cell sent before then is discarded and the
    -- cell stays held forever. Callers usually run a cell straight away.
    local finished = false
    local function finish(value, err)
      if finished then return end
      finished = true
      if not value then vim.notify("Notebook kernel: " .. err, vim.log.levels.ERROR) end
      callback(value, err)
    end
    local ready
    if not shared then
      ready = vim.api.nvim_create_autocmd("User", {
        pattern = "MoltenKernelReady",
        callback = function(ev)
          if ev.data and contains(attached(buf), ev.data.kernel_id) then
            vim.schedule(function() finish(info) end)
            return true
          end
        end,
      })
    end

    local ok, init_err = pcall(vim.api.nvim_buf_call, buf, function()
      vim.cmd("MoltenInit " .. (shared and "shared " or "") .. info.name)
    end)
    -- Molten reports init failures as notifications, not errors.
    if ok and not contains(attached(buf), info.name) then
      ok, init_err = false, "Molten could not start " .. info.name .. " (" .. info.python .. "); see its notification for the cause"
    end
    if not ok then
      if ready then pcall(vim.api.nvim_del_autocmd, ready) end
      return finish(nil, tostring(init_err))
    end
    vim.b[buf].kit_kernel = info
    vim.notify("Notebook kernel " .. info.name .. ": " .. info.python)
    if shared then return finish(info) end
    vim.defer_fn(function()
      if finished then return end
      pcall(vim.api.nvim_del_autocmd, ready)
      finish(nil, info.name .. " did not become ready within " .. M.ready_timeout / 1000 .. " s")
    end, M.ready_timeout)
  end)
end

M.ready_timeout = 60000

local function notebook_path(buf)
  local path = vim.api.nvim_buf_get_name(buf)
  return path:match("%.ipynb$") and path or nil
end

-- Shows outputs stored in an .ipynb in the attached kernel, then calls done().
-- Explicit only (:NotebookLoadOutputs): Molten applies the import
-- asynchronously and it deletes overlapping cells, so importing when a kernel
-- starts would wipe the output of a cell run straight afterwards. Molten's host
-- can also be busy just after init and reject the request ("Request from
-- non-main thread"), so retry briefly before giving up.
M.import_retries = 10
M.import_delay = 200

function M.import(buf, name, done, attempt)
  done = done or function() end
  attempt = attempt or 1
  local path = notebook_path(buf)
  if not path or vim.fn.filereadable(path) ~= 1 then return done() end
  vim.defer_fn(function()
    if not vim.api.nvim_buf_is_valid(buf) then return done() end
    local ok, err = pcall(vim.api.nvim_buf_call, buf, function()
      vim.cmd("MoltenImportOutput " .. vim.fn.fnameescape(path) .. " " .. name)
    end)
    if ok then return done() end
    if tostring(err):find("non-main thread", 1, true) and attempt < M.import_retries then
      return M.import(buf, name, done, attempt + 1)
    end
    vim.notify("Could not load stored outputs: " .. tostring(err), vim.log.levels.WARN)
    done()
  end, attempt == 1 and 0 or M.import_delay)
end

-- Writes the kernel's outputs into the saved .ipynb (after Jupytext has
-- written the cells). Without "!" Molten writes a sibling copy-of-*.ipynb
-- instead, so always overwrite the file being saved. Buffers without a kernel
-- have no outputs to write.
function M.export(buf, path)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  path = path or notebook_path(buf)
  if not path then return end
  local kernels = attached(buf)
  if #kernels == 0 then return end
  local name = (vim.b[buf].kit_kernel or {}).name
  if not contains(kernels, name) then name = kernels[1] end
  local ok, err = pcall(vim.api.nvim_buf_call, buf, function()
    vim.cmd("noautocmd MoltenExportOutput! " .. vim.fn.fnameescape(path) .. " " .. name)
  end)
  if not ok then vim.notify("Notebook outputs were not saved: " .. tostring(err), vim.log.levels.ERROR) end
end

-- Runs fn once buf has a kernel, starting the project kernel if needed.
function M.ensure(buf, fn)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  if #attached(buf) > 0 then return fn(vim.b[buf].kit_kernel) end
  M.start(buf, function(info)
    if info then fn(info) end
  end)
end

function M.info(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local info = vim.b[buf].kit_kernel
  local kernels = attached(buf)
  if #kernels == 0 then return vim.notify("No notebook kernel attached to this buffer") end
  vim.notify("Notebook kernel " .. table.concat(kernels, ", ") .. (info and (": " .. info.python .. " (" .. info.root .. ")") or ""))
end

function M.select(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local root = require("kit.project").root(vim.api.nvim_buf_get_name(buf))
  local env = require("kit.python_env")
  local choices = env.choices(root)
  vim.ui.select(choices, {
    prompt = "Notebook kernel environment (" .. root .. ")",
    format_item = function(item) return item.label end,
  }, function(choice)
    if not choice then return end
    env.set(root, choice)
    M.start(buf)
  end)
end

function M.commands()
  vim.api.nvim_create_user_command("NotebookKernel", function() M.start(0) end,
    { desc = "Start the project kernel for this buffer" })
  vim.api.nvim_create_user_command("NotebookKernelSelect", function() M.select(0) end,
    { desc = "Choose the project environment and start its kernel" })
  vim.api.nvim_create_user_command("NotebookKernelInfo", function() M.info(0) end,
    { desc = "Show the kernel attached to this buffer" })
  vim.api.nvim_create_user_command("NotebookLoadOutputs", function() M.load_outputs(0) end,
    { desc = "Show the outputs saved in this .ipynb (starts the kernel if needed)" })
end

-- Loads the outputs saved in the buffer's .ipynb into its kernel.
function M.load_outputs(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  if not notebook_path(buf) then return vim.notify("Saved outputs are only available for .ipynb files") end
  M.ensure(buf, function(info)
    local name = (info and info.name) or attached(buf)[1]
    if name then M.import(buf, name) end
  end)
end

return M

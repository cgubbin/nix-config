_: {
  flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-telescope" =
    {
      config,
      pkgs,
      ...
    }:
    let
      helpers = config.lib.nixvim;
    in
    {
      programs.nixvim = {
        plugins = {
          web-devicons.enable = true;
          diffview.enable = true;
          octo = {
            enable = true;
            settings.picker = "telescope";
          };

          telescope = {
            enable = true;

            extensions = {
              file-browser.enable = true;
              fzf-native = {
                enable = true;
                settings = {
                  fuzzy = true;
                  override_generic_sorter = true;
                  override_file_sorter = true;
                  case_mode = "smart_case";
                };
              };
            };

            settings = {
              defaults = {
                border = true;
                layout_strategy = "horizontal";
                sorting_strategy = "ascending";
                prompt_prefix = "   ";
                selection_caret = " ";
                path_display = [ "smart" ];
                mappings = {
                  i = {
                    "<Esc>" = "close";
                  };
                };
              };

              pickers = {
                find_files = {
                  theme = "ivy";
                };
                live_grep = {
                  theme = "ivy";
                };
                oldfiles = {
                  theme = "ivy";
                };
                buffers = {
                  theme = "dropdown";
                  previewer = false;
                  sort_mru = true;
                  ignore_current_buffer = true;
                };
                help_tags = {
                  theme = "dropdown";
                };
              };
            };
          };
        };

        extraPackages = with pkgs; [
          ripgrep
          fd
          gh
        ];

        extraConfigLua = ''
          require("telescope").load_extension("fzf")
          require("telescope").load_extension("file_browser")
        '';

        keymaps = [
          {
            mode = "n";
            key = "<leader>gP";
            action = "<cmd>Octo pr list<CR>";
            options.desc = "GitHub pull requests";
          }
          {
            mode = "n";
            key = "<leader>gd";
            action = "<cmd>DiffviewOpen<CR>";
            options.desc = "Review working tree and conflicts";
          }
          {
            mode = "n";
            key = "<leader>gD";
            action = "<cmd>DiffviewClose<CR>";
            options.desc = "Close diff view";
          }
          {
            mode = "n";
            key = "<leader>gH";
            action = "<cmd>DiffviewFileHistory %<CR>";
            options.desc = "Current file history";
          }
          {
            mode = "n";
            key = "<space>en";
            action = helpers.mkRaw ''
              function()
                local dir = vim.g.shared_editor_config_directory
                if not dir or vim.fn.isdirectory(dir) ~= 1 then
                  vim.notify("Configure an existing sharedEditor.configDirectory", vim.log.levels.WARN)
                  return
                end
                require("kit.telescope").find_files_enhanced({
                  cwd = dir,
                  prompt_title = "Nixvim Config";
                  hidden = true;
                })
              end
            '';
            options.desc = "Find files in Neovim config";
          }
          {
            mode = "n";
            key = "<space>fd";
            action = helpers.mkRaw ''
              function()
                require("kit.telescope").find_files_enhanced({
                  hidden = true;
                })
              end
            '';
            options.desc = "Find files in cwd";
          }
          {
            mode = "n";
            key = "<space>fm";
            action = helpers.mkRaw ''
              function()
                require("kit.telescope").find_matching_files()
              end
            '';
            options.desc = "Find files matching current buffer name";
          }
          {
            mode = "n";
            key = "<space>fr";
            action = helpers.mkRaw ''
              function()
                require("telescope.builtin").oldfiles()
              end
            '';
            options.desc = "Find recent files";
          }
          {
            mode = "n";
            key = "<space>fs";
            action = helpers.mkRaw ''
              function()
                require("kit.telescope").live_grep_enhanced()
              end
            '';
            options.desc = "Live grep in cwd";
          }
          {
            mode = "n";
            key = "<space>fc";
            action = helpers.mkRaw ''
              function()
                require("kit.telescope").grep_string_enhanced()
              end
            '';
            options.desc = "Grep word under cursor";
          }
          {
            mode = "n";
            key = "<space>fh";
            action = helpers.mkRaw ''
              function()
                require("telescope.builtin").help_tags()
              end
            '';
            options.desc = "Help tags";
          }
          {
            mode = "n";
            key = "<space>fg";
            action = helpers.mkRaw ''
              function()
                require("kit.telescope").git_files_fallback()
              end
            '';
            options.desc = "Git files, fallback to find_files";
          }
          {
            mode = "n";
            key = "<space>fC";
            action = helpers.mkRaw ''
              function()
                require("kit.telescope").git_commits_enhanced()
              end
            '';
            options.desc = "Git commits";
          }
          {
            mode = "n";
            key = "<space>fB";
            action = helpers.mkRaw ''
              function()
                require("kit.telescope").git_branches_enhanced()
              end
            '';
            options.desc = "Git branches";
          }
          {
            mode = "n";
            key = "<leader>fg";
            action = helpers.mkRaw ''
              function()
                require("kit.telescope").live_multigrep()
              end
            '';
            options.desc = "Multi grep: pattern :: glob";
          }
          {
            mode = "n";
            key = "<space>fb";
            action = helpers.mkRaw ''
              function()
                require("kit.telescope").file_browser_here()
              end
            '';
            options.desc = "File browser";
          }
        ];
      };

      xdg.configFile."nvim/lua/kit/telescope.lua".text = ''
        local M = {}

        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local builtin = require("telescope.builtin")
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local make_entry = require("telescope.make_entry")
        local conf = require("telescope.config").values
        local sorters = require("telescope.sorters")
        local themes = require("telescope.themes")

        local u = require("kit.functions.utils")

        local function clipboard_register()
          return vim.fn.has("clipboard") == 1 and "+" or '"'
        end

        local function close_and(fn)
          return function(prompt_bufnr)
            fn(prompt_bufnr)
            actions.close(prompt_bufnr)
          end
        end

        local function selected_entry(prompt_bufnr)
          return action_state.get_selected_entry()
        end

        local function selected_value(prompt_bufnr)
          local entry = selected_entry(prompt_bufnr)
          return entry and entry.value or nil
        end

        local function selected_text(prompt_bufnr)
          local entry = selected_entry(prompt_bufnr)
          if not entry then
            return ""
          end
          return vim.trim(entry.text or entry.value or "")
        end

        local function send_to_quickfix(prompt_bufnr)
          actions.smart_add_to_qflist(prompt_bufnr)
          actions.open_qflist(prompt_bufnr)
        end

        local function copy_text_from_preview(prompt_bufnr)
          vim.fn.setreg(clipboard_register(), selected_text(prompt_bufnr))
        end

        local function copy_commit_hash(prompt_bufnr)
          local value = selected_value(prompt_bufnr)
          if value then
            vim.fn.setreg(clipboard_register(), value)
          end
        end

        local function see_commit_changes_in_diffview(prompt_bufnr)
          local value = selected_value(prompt_bufnr)
          if value then
            vim.api.nvim_cmd({ cmd = "DiffviewOpen", args = { value .. "^!" } }, {})
          end
        end

        local function compare_with_current_branch_in_diffview(prompt_bufnr)
          local value = selected_value(prompt_bufnr)
          if value then
            vim.api.nvim_cmd({ cmd = "DiffviewOpen", args = { value } }, {})
          end
        end

        local function open_in_oil(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)

          local dir = selection.path or selection.filename or selection.value
          if not dir then
            return
          end

          vim.cmd("tabnew")

          local ok_plugin, plugin_oil = pcall(require, "plugins.oil")
          if ok_plugin and plugin_oil.open_dir then
            plugin_oil.open_dir(dir)
            return
          end

          local ok_oil, oil = pcall(require, "oil")
          if ok_oil then
            oil.open(dir)
          end
        end

        local function apply_common_mappings(map)
          map("i", "<C-q>", send_to_quickfix)
          map("n", "<C-q>", send_to_quickfix)
        end

        local function apply_copy_mappings(map)
          map("i", "<C-y>", close_and(copy_text_from_preview))
          map("n", "<C-y>", close_and(copy_text_from_preview))
        end

        local function apply_commit_copy_mappings(map)
          map("i", "<C-y>", close_and(copy_commit_hash))
          map("n", "<C-y>", close_and(copy_commit_hash))
        end

        local function attach_with(setup)
          return function(_, map)
            apply_common_mappings(map)
            if setup then
              setup(map)
            end
            return true
          end
        end

        function M.find_matching_files()
          local bare_file_name = u.return_bare_file_name()
          builtin.find_files({ default_text = bare_file_name })
        end

        function M.git_files_fallback()
          local ok = pcall(builtin.git_files)
          if not ok then
            builtin.find_files()
          end
        end

        function M.grep_string_with_word()
          builtin.grep_string({ search = vim.fn.expand("<cword>") })
        end

        function M.git_commits_enhanced()
          builtin.git_commits({
            attach_mappings = attach_with(function(map)
              map("i", "<C-d>", close_and(see_commit_changes_in_diffview))
              map("n", "<C-d>", close_and(see_commit_changes_in_diffview))
              apply_commit_copy_mappings(map)
            end),
          })
        end

        function M.git_branches_enhanced()
          builtin.git_branches({
            attach_mappings = attach_with(function(map)
              map("i", "<C-d>", close_and(compare_with_current_branch_in_diffview))
              map("n", "<C-d>", close_and(compare_with_current_branch_in_diffview))
            end),
          })
        end

        function M.find_files_enhanced(opts)
          opts = opts or {}
          builtin.find_files(vim.tbl_extend("force", opts, {
            attach_mappings = attach_with(function(map)
              map("i", "<C-o>", close_and(open_in_oil))
              map("n", "<C-o>", close_and(open_in_oil))
            end),
          }))
        end

        function M.live_grep_enhanced()
          builtin.live_grep({
            attach_mappings = attach_with(function(map)
              apply_copy_mappings(map)
            end),
          })
        end

        function M.grep_string_enhanced()
          builtin.grep_string({
            search = vim.fn.expand("<cword>"),
            attach_mappings = attach_with(function(map)
              apply_copy_mappings(map)
            end),
          })
        end

        function M.live_multigrep(opts)
          opts = opts or {}
          opts.cwd = opts.cwd or vim.uv.cwd()

          local finder = finders.new_async_job({
            command_generator = function(prompt)
              if not prompt or prompt == "" then
                return nil
              end

              local pieces = vim.split(prompt, "::", { plain = true, trimempty = true })
              local pattern = vim.trim(pieces[1] or "")
              local glob = vim.trim(pieces[2] or "")

              if pattern == "" then
                return nil
              end

              local args = {
                "rg",
                "-e", pattern,
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case",
              }

              if glob ~= "" then
                table.insert(args, "-g")
                table.insert(args, glob)
              end

              return args
            end,
            entry_maker = make_entry.gen_from_vimgrep(opts),
            cwd = opts.cwd,
          })

          pickers.new(themes.get_ivy(opts), {
            debounce = 100,
            prompt_title = "Multi Grep (pattern :: glob)",
            finder = finder,
            previewer = conf.grep_previewer(opts),
            sorter = sorters.empty(),
            attach_mappings = attach_with(function(map)
              apply_copy_mappings(map)
            end),
          }):find()
        end

        function M.file_browser_here()
          telescope.extensions.file_browser.file_browser(themes.get_dropdown({
            path = "%:p:h",
            select_buffer = true,
            hidden = true,
            respect_gitignore = false,
          }))
        end

        return M
      '';
    };
}

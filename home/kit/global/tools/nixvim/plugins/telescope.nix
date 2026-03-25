{
  config,
  pkgs,
  ...
}: let
  helpers = config.lib.nixvim;
in {
  programs.nixvim = {
    plugins = {
      web-devicons.enable = true;

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
          };

          pickers = {
            find_files = {
              theme = "ivy";
            };
          };
        };
      };
    };

    extraPackages = with pkgs; [
      ripgrep
    ];

    extraConfigLua = ''
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local builtin = require("telescope.builtin")

      -- Keep only if this module still exists in your config.
      local u = require("kit.functions.utils")

      _G.find_matching_files = function()
        local bare_file_name = u.return_bare_file_name()
        builtin.find_files({ default_text = bare_file_name })
      end

      _G.git_files_fallback = function()
        local ok = pcall(builtin.git_files)
        if not ok then
          builtin.find_files()
        end
      end

      _G.grep_string_with_word = function()
        local word = vim.fn.expand("<cword>")
        builtin.grep_string()
        vim.api.nvim_feedkeys(word, "i", false)
      end

      local function see_commit_changes_in_diffview(prompt_bufnr)
        actions.close(prompt_bufnr)
        local value = action_state.get_selected_entry().value
        vim.cmd("DiffviewOpen " .. value .. "~1.." .. value)
      end

      local function compare_with_current_branch_in_diffview(prompt_bufnr)
        actions.close(prompt_bufnr)
        local value = action_state.get_selected_entry().value
        vim.cmd("DiffviewOpen " .. value)
      end

      local function copy_text_from_preview(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        local text = vim.fn.trim(selection["text"] or "")
        local os = u.get_os() == "Darwin" and "mac" or "linux"

        if os == "mac" then
          vim.fn.setreg("*", text)
        else
          vim.fn.setreg('"', text)
        end

        actions.close(prompt_bufnr)
      end

      local function copy_commit_hash(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        local os = u.get_os() == "Darwin" and "mac" or "linux"

        if os == "mac" then
          vim.fn.setreg("*", selection.value)
        else
          vim.fn.setreg('"', selection.value)
        end

        actions.close(prompt_bufnr)
      end

      local function send_to_quickfix(prompt_bufnr)
        actions.smart_add_to_qflist(prompt_bufnr)
        actions.open_qflist(prompt_bufnr)
      end

      local function open_in_oil(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        require("plugins.oil").open_dir(selection.value)
      end

      _G.git_commits_enhanced = function()
        builtin.git_commits({
          attach_mappings = function(_, map)
            map("i", "<C-d>", see_commit_changes_in_diffview)
            map("n", "<C-d>", see_commit_changes_in_diffview)

            map("i", "<C-y>", copy_commit_hash)
            map("n", "<C-y>", copy_commit_hash)

            map("i", "<C-q>", send_to_quickfix)
            map("n", "<C-q>", send_to_quickfix)

            return true
          end,
        })
      end

      _G.git_branches_enhanced = function()
        builtin.git_branches({
          attach_mappings = function(_, map)
            map("i", "<C-d>", compare_with_current_branch_in_diffview)
            map("n", "<C-d>", compare_with_current_branch_in_diffview)

            map("i", "<C-q>", send_to_quickfix)
            map("n", "<C-q>", send_to_quickfix)

            return true
          end,
        })
      end

      _G.find_files_enhanced = function(opts)
        opts = opts or {}
        builtin.find_files(vim.tbl_extend("force", opts, {
          attach_mappings = function(_, map)
            map("i", "<C-o>", open_in_oil)
            map("n", "<C-o>", open_in_oil)

            map("i", "<C-q>", send_to_quickfix)
            map("n", "<C-q>", send_to_quickfix)

            return true
          end,
        }))
      end

      _G.live_grep_enhanced = function()
        builtin.live_grep({
          attach_mappings = function(_, map)
            map("i", "<C-y>", copy_text_from_preview)
            map("n", "<C-y>", copy_text_from_preview)

            map("i", "<C-q>", send_to_quickfix)
            map("n", "<C-q>", send_to_quickfix)

            return true
          end,
        })
      end

      _G.grep_string_enhanced = function()
        local word = vim.fn.expand("<cword>")
        builtin.grep_string({
          attach_mappings = function(_, map)
            map("i", "<C-y>", copy_text_from_preview)
            map("n", "<C-y>", copy_text_from_preview)

            map("i", "<C-q>", send_to_quickfix)
            map("n", "<C-q>", send_to_quickfix)

            return true
          end,
        })
        vim.api.nvim_feedkeys(word, "i", false)
      end

      _G.live_multigrep = function(opts)
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local make_entry = require("telescope.make_entry")
        local conf = require("telescope.config").values

        opts = opts or {}
        opts.cwd = opts.cwd or vim.uv.cwd()

        local finder = finders.new_async_job {
          command_generator = function(prompt)
            if not prompt or prompt == "" then
              return nil
            end

            local pieces = vim.split(prompt, "  ")
            local args = { "rg" }

            if pieces[1] then
              table.insert(args, "-e")
              table.insert(args, pieces[1])
            end

            if pieces[2] then
              table.insert(args, "-g")
              table.insert(args, pieces[2])
            end

            return vim.tbl_flatten {
              args,
              {
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case"
              }
            }
          end,
          entry_maker = make_entry.gen_from_vimgrep(opts),
          cwd = opts.cwd,
        }

        pickers.new(opts, {
          debounce = 100,
          prompt_title = "Multi Grep",
          finder = finder,
          previewer = conf.grep_previewer(opts),
          sorter = require("telescope.sorters").empty(),
          theme = "ivy",
          attach_mappings = function(_, map)
            map("i", "<C-y>", copy_text_from_preview)
            map("n", "<C-y>", copy_text_from_preview)

            map("i", "<C-q>", send_to_quickfix)
            map("n", "<C-q>", send_to_quickfix)

            return true
          end,
        }):find()
      end
    '';

    keymaps = [
      {
        mode = "n";
        key = "<space>en";
        action = helpers.mkRaw ''
          function()
            _G.find_files_enhanced({
              cwd = "/Users/kit/.config/nix/home/programs/neovim"
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
            _G.find_files_enhanced()
          end
        '';
        options.desc = "Find files in cwd";
      }
      {
        mode = "n";
        key = "<space>fm";
        action = helpers.mkRaw ''
          function()
            _G.find_matching_files()
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
            _G.live_grep_enhanced()
          end
        '';
        options.desc = "Live grep in cwd";
      }
      {
        mode = "n";
        key = "<space>fc";
        action = helpers.mkRaw ''
          function()
            _G.grep_string_enhanced()
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
            _G.git_files_fallback()
          end
        '';
        options.desc = "Git files, fallback to find_files";
      }
      {
        mode = "n";
        key = "<space>fC";
        action = helpers.mkRaw ''
          function()
            _G.git_commits_enhanced()
          end
        '';
        options.desc = "Git commits";
      }
      {
        mode = "n";
        key = "<space>fB";
        action = helpers.mkRaw ''
          function()
            _G.git_branches_enhanced()
          end
        '';
        options.desc = "Git branches";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = helpers.mkRaw ''
          function()
            _G.live_multigrep()
          end
        '';
        options.desc = "Multi grep: pattern  <space><space>  glob";
      }
      {
        mode = "n";
        key = "<space>fb";
        action = helpers.mkRaw ''
          function()
            require("telescope").extensions.file_browser.file_browser({
                path = "%:p:h",
                select_buffer = true,
                hidden = true,
                respect_gitignore = false,
            })
          end
        '';
        options.desc = "File browser";
      }
    ];
  };
}

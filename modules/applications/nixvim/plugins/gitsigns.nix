_: {
  flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-gitsigns" = _: {
    programs.nixvim = {
      plugins.gitsigns = {
        enable = true;

        settings = {
          signs = {
            add = {
              text = "│";
            };
            change = {
              text = "│";
            };
            delete = {
              text = "_";
            };
            topdelete = {
              text = "‾";
            };
            changedelete = {
              text = "~";
            };
            untracked = {
              text = "┆";
            };
          };

          signcolumn = true;
          numhl = false;
          linehl = false;

          word_diff = false;

          watch_gitdir = {
            interval = 1000;
            follow_files = true;
          };

          current_line_blame = false;

          update_debounce = 200;
          max_file_length = 40000;
          preview_config = {
            border = "rounded";
            style = "minimal";
            relative = "cursor";
            row = 0;
            col = 1;
          };
        };
      };

      keymaps = [
        # Navigation
        {
          mode = "n";
          key = "]c";
          action = "<cmd>Gitsigns next_hunk<CR>";
          options.desc = "Next hunk";
        }
        {
          mode = "n";
          key = "[c";
          action = "<cmd>Gitsigns prev_hunk<CR>";
          options.desc = "Prev hunk";
        }

        # Actions
        {
          mode = "n";
          key = "<leader>hs";
          action = "<cmd>Gitsigns stage_hunk<CR>";
          options.desc = "Stage hunk";
        }
        {
          mode = "n";
          key = "<leader>hr";
          action = "<cmd>Gitsigns reset_hunk<CR>";
          options.desc = "Reset hunk";
        }
        {
          mode = "n";
          key = "<leader>hS";
          action = "<cmd>Gitsigns stage_buffer<CR>";
          options.desc = "Stage buffer";
        }
        {
          mode = "n";
          key = "<leader>hu";
          action = "<cmd>Gitsigns undo_stage_hunk<CR>";
          options.desc = "Undo stage hunk";
        }
        {
          mode = "n";
          key = "<leader>hR";
          action = "<cmd>Gitsigns reset_buffer<CR>";
          options.desc = "Reset buffer";
        }

        # Preview
        {
          mode = "n";
          key = "<leader>hP";
          action = "<cmd>Gitsigns preview_hunk<CR>";
          options.desc = "Preview hunk";
        }

        # Blame
        {
          mode = "n";
          key = "<leader>hb";
          action = "<cmd>Gitsigns blame_line<CR>";
          options.desc = "Blame line";
        }

        # Toggle
        {
          mode = "n";
          key = "<leader>ht";
          action = "<cmd>Gitsigns toggle_current_line_blame<CR>";
          options.desc = "Toggle blame";
        }
      ];
    };
  };
}

{config, ...}: {
  programs.nixvim = {
    plugins.obsidian = {
      enable = true;
      lazyLoad = {
        enable = false;
        settings = {
          ft = ["markdown"];
          event = [
            "BufReadPre ~/obsidian/main/**.md"
            "BufNewFile ~/obsidian/main/**.md"
          ];
        };
      };

      settings = {
        completion = {
          min_chars = 2;
          nvim_cmp = true;
        };
        workspaces = [
          {
            name = "metrology";
            path = "${config.home.homeDirectory}/obsidian/main/Metrology";
          }
          {
            name = "premed";
            path = "${config.home.homeDirectory}/obsidian/main/PreMed/Premed";
          }
        ];

        new_notes_location = "notes_subdir";
        notes_subdir = "inbox";

        templates = {
          folder = "templates";
          date_format = "%Y-%m-%d";
          time_format = "%H:%M";
        };

        daily_notes = {
          folder = "daily";
          date_format = "%Y-%m-%d";
          alias_format = "%B %-d, %Y";
          template = "daily.md";
        };

        preferred_link_style = "wiki";
      };
    };

    keymaps = [
      # Find or open
      {
        mode = "n";
        key = "<leader>of";
        action = "<cmd>ObsidianQuickSwitch<cr>";
        options.desc = "Find note";
      }
      {
        mode = "n";
        key = "<leader>os";
        action = "<cmd>ObsidianSearch<cr>";
        options.desc = "Search notes";
      }
      {
        mode = "n";
        key = "<leader>oo";
        action = "<cmd>ObsidianOpen<cr>";
        options.desc = "Open in obsidian";
      }
      # Create
      {
        mode = "n";
        key = "<leader>on";
        action = "<cmd>ObsidianNew<cr>";
        options.desc = "New note";
      }
      {
        mode = "n";
        key = "<leader>od";
        action = "<cmd>ObsidianToday<cr>";
        options.desc = "Today note";
      }
      {
        mode = "n";
        key = "<leader>oy";
        action = "<cmd>ObsidianYesterday<cr>";
        options.desc = "Yesterday note";
      }
      {
        mode = "n";
        key = "<leader>om";
        action = "<cmd>ObsidianTomorrow<cr>";
        options.desc = "Tomorrow note";
      }
      {
        mode = "n";
        key = "<leader>oD";
        action = "<cmd>ObsidianDailies<cr>";
        options.desc = "Daily notes";
      }
      # Navigate or inspect
      {
        mode = "n";
        key = "<leader>ob";
        action = "<cmd>ObsidianBacklinks<cr>";
        options.desc = "Backlinks";
      }
      {
        mode = "n";
        key = "<leader>ot";
        action = "<cmd>ObsidianTags<cr>";
        options.desc = "Tags";
      }
      {
        mode = "n";
        key = "<leader>ol";
        action = "<cmd>ObsidianLinks<cr>";
        options.desc = "Links";
      }
      # Maintenance
      {
        mode = "n";
        key = "<leader>or";
        action = "<cmd>ObsidianRename<cr>";
        options.desc = "Rename note";
      }
      {
        mode = "n";
        key = "<leader>ow";
        action = "<cmd>ObsidianWorkspace<cr>";
        options.desc = "Switch workspace";
      }
    ];

    autoCmd = [
      {
        event = ["BufReadPost" "BufNewFile"];
        pattern = ["*.md"];
        callback.__raw = ''
          function()
              local path = vim.fn.expand("%:p")
              local home = vim.fn.expand("${config.home.homeDirectory}")
              if path:find(home .. "/obsidian/main", 1, true) == 1 then
                  vim.opt_local.wrap = true;
                  vim.opt_local.spell = true;
                  vim.opt_local.conceallevel = 2;
              end
          end
        '';
      }
    ];
  };
}

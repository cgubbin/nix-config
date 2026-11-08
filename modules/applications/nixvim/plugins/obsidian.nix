_: {
  flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-obsidian" = { config, ... }: {
    programs.nixvim = {
      plugins.obsidian = {
        enable = true;
        autoLoad = true;

        lazyLoad = {
          enable = false;
        };

        settings = {
          legacy_commands = false;

          workspaces = [
            {
              name = "metrology";
              path = "${config.home.homeDirectory}/obsidian/main/Sensorium";
              overrides = {
                notes_subdir = "98_INBOX";

                templates = {
                  folder = "00_System/templates";
                  date_format = "%Y-%m-%d";
                  time_format = "%H:%M";
                  substitutions = {
                    area = "sensorium";
                  };
                };

                daily_notes = {
                  folder = "daily";
                  date_format = "%Y-%m-%d";
                  alias_format = "%B %-d, %Y";
                  template = "daily.md";
                };
              };
            }
            # {
            #   name = "metrology";
            #   path = "${config.home.homeDirectory}/obsidian/main/Metrology";
            #   overrides = {
            #     notes_subdir = "inbox";

            #     templates = {
            #       folder = "templates";
            #       date_format = "%Y-%m-%d";
            #       time_format = "%H:%M";
            #       substitutions = {
            #         area = "metrology";
            #       };
            #     };

            #     daily_notes = {
            #       folder = "daily";
            #       date_format = "%Y-%m-%d";
            #       alias_format = "%B %-d, %Y";
            #       template = "daily.md";
            #     };
            #   };
            # }
            {
              name = "premed";
              path = "${config.home.homeDirectory}/obsidian/main/Premed/Premed";
              overrides = {
                notes_subdir = "98_INBOX";

                templates = {
                  folder = "99_TEMPLATES";
                  date_format = "%Y-%m-%d";
                  time_format = "%H:%M";
                  substitutions = {
                    area = "premed";
                  };
                };

                daily_notes = {
                  folder = "daily";
                  date_format = "%Y-%m-%d";
                  alias_format = "%B %-d, %Y";
                  template = "daily.md";
                };
              };
            }
          ];

          completion = {
            min_chars = 2;
            nvim_cmp = true;
          };

          new_notes_location = "notes_subdir";
          notes_subdir = "98_INBOX";

          templates = {
            folder = "templates";
            date_format = "%Y-%m-%d";
            time_format = "%H:%M";
            substitutions = {
              yesterday.__raw = ''
                function()
                  return os.date("%Y-%m-%d", os.time() - 86400)
                end
              '';
              tomorrow.__raw = ''
                function()
                  return os.date("%Y-%m-%d", os.time() + 86400)
                end
              '';
            };
          };

          daily_notes = {
            folder = "daily";
            date_format = "%Y-%m-%d";
            alias_format = "%B %-d, %Y";
            template = "daily.md";
          };

          preferred_link_style = "wiki";
          search.sort_by = "modified";
          search.sort_reversed = true;

          frontmatter.func.__raw = ''
            function(note)
              local client = require("obsidian").get_client()
              if not client then
                return {}
              end
              local ws = rawget(_G, "Obsidian") and Obsidian.workspace or nil
              local workspace_name = ws and ws.name or "unknown"
              local now = os.date("!%Y-%m-%dT%H:%M:%SZ")

              local out = {
                id = note.id,
                aliases = note.aliases or {},
                tags = note.tags or {},
              }

              if note.title and note.title ~= "" then
                out.title = note.title
              end

              if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
                for k, v in pairs(note.metadata) do
                  out[k] = v
                end
              end

              if out.created == nil or out.created == "" then
                out.created = now
              end
              out.updated = now

              if workspace_name == "premed" then
                if out.area == nil then out.area = "premed" end
                if out.status == nil then out.status = "active" end
                if out.subject == nil then out.subject = "" end
                if out.topic == nil then out.topic = "" end
                if out.type == nil then out.type = "" end
                if out.mastery == nil then out.mastery = "new" end
                if out.importance == nil then out.importance = "high" end
              else
                if out.area == nil then out.area = workspace_name end
                if out.status == nil then out.status = "seed" end
                if out.kind == nil then out.kind = "note" end
              end

              return out
            end
          '';
        };
      };

      keymaps = [
        {
          mode = "n";
          key = "<leader>of";
          action = "<cmd>Obsidian quick_switch<cr>";
          options.desc = "Find note";
        }
        {
          mode = "n";
          key = "<leader>os";
          action = "<cmd>Obsidian search<cr>";
          options.desc = "Search notes";
        }
        {
          mode = "n";
          key = "<leader>oo";
          action = "<cmd>Obsidian open<cr>";
          options.desc = "Open in Obsidian";
        }
        {
          mode = "n";
          key = "<leader>ow";
          action = "<cmd>Obsidian workspace<cr>";
          options.desc = "Switch workspace";
        }

        {
          mode = "n";
          key = "<leader>on";
          action = "<cmd>Obsidian new<cr>";
          options.desc = "New note";
        }
        {
          mode = "n";
          key = "<leader>oN";
          action = "<cmd>Obsidian new_from_template<cr>";
          options.desc = "New note from template";
        }
        {
          mode = "n";
          key = "<leader>oT";
          action = "<cmd>Obsidian template<cr>";
          options.desc = "Insert template";
        }
        {
          mode = "n";
          key = "<leader>od";
          action = "<cmd>Obsidian today<cr>";
          options.desc = "Today note";
        }
        {
          mode = "n";
          key = "<leader>oy";
          action = "<cmd>Obsidian yesterday<cr>";
          options.desc = "Yesterday note";
        }
        {
          mode = "n";
          key = "<leader>om";
          action = "<cmd>Obsidian tomorrow<cr>";
          options.desc = "Tomorrow note";
        }
        {
          mode = "n";
          key = "<leader>oD";
          action = "<cmd>Obsidian dailies<cr>";
          options.desc = "Daily notes";
        }

        {
          mode = "n";
          key = "<leader>ol";
          action = "<cmd>Obsidian follow_link<cr>";
          options.desc = "Follow link";
        }
        {
          mode = "n";
          key = "<leader>ob";
          action = "<cmd>Obsidian backlinks<cr>";
          options.desc = "Backlinks";
        }
        {
          mode = "n";
          key = "<leader>oL";
          action = "<cmd>Obsidian links<cr>";
          options.desc = "Links";
        }
        {
          mode = "n";
          key = "<leader>ot";
          action = "<cmd>Obsidian tags<cr>";
          options.desc = "Tags";
        }
        {
          mode = "n";
          key = "<leader>oc";
          action = "<cmd>Obsidian toggle_checkbox<cr>";
          options.desc = "Toggle checkbox";
        }
        {
          mode = "n";
          key = "<leader>oC";
          action = "<cmd>Obsidian toc<cr>";
          options.desc = "Table of contents";
        }

        {
          mode = "n";
          key = "<leader>or";
          action = "<cmd>Obsidian rename<cr>";
          options.desc = "Rename note";
        }
      ];

      autoCmd = [
        {
          event = [
            "BufReadPost"
            "BufNewFile"
          ];
          pattern = [ "*.md" ];
          callback.__raw = ''
            function()
              local path = vim.fn.expand("%:p")
              local home = vim.fn.expand("${config.home.homeDirectory}")

              if path:find(home .. "/obsidian/main", 1, true) == 1 then
                vim.opt_local.wrap = true
                vim.opt_local.linebreak = true
                vim.opt_local.breakindent = true
                vim.opt_local.spell = true
                vim.opt_local.conceallevel = 2
              end
            end
          '';
        }
        {
          event = [ "BufWritePre" ];
          pattern = [ "*.md" ];
          callback.__raw = ''
            function()
              local path = vim.fn.expand("%:p")
              local home = vim.fn.expand("${config.home.homeDirectory}")

              if path:find(home .. "/obsidian/main", 1, true) ~= 1 then
                return
              end

              local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
              if #lines == 0 or lines[1] ~= "---" then
                return
              end

              local now = os.date("!%Y-%m-%dT%H:%M:%SZ")
              local end_idx = nil

              for i = 2, math.min(#lines, 80) do
                if lines[i] == "---" then
                  end_idx = i
                  break
                end
              end

              if end_idx == nil then
                return
              end

              local updated_found = false

              for i = 2, end_idx - 1 do
                if lines[i]:match("^updated:%s*") then
                  lines[i] = "updated: " .. now
                  updated_found = true
                  break
                end
              end

              if not updated_found then
                table.insert(lines, end_idx, "updated: " .. now)
              end

              vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)

            end
          '';
        }
      ];
    };
  };
}

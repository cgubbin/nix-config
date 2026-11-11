_: {
  flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-notebook" = { config, lib, ... }: {
    programs.nixvim = {
      extraPlugins = lib.optional (
        config.sharedEditor.quartoSyncPackage != null
      ) config.sharedEditor.quartoSyncPackage;
      plugins = {
        quarto = {
          enable = true;
          settings = {
            lspFeatures = {
              enabled = true;
              chunks = "curly";
              languages = [
                "r"
                "python"
                "julia"
                "bash"
              ];
              diagnostics = {
                enabled = true;
                triggers = [ "BufWritePost" ];
              };
              completion.enabled = true;
            };

            codeRunner = {
              enabled = true;
              default_method = "molten";
              ft_runners = {
                quarto = "molten";
                markdown = "molten";
              };
            };
          };
        };

        jupytext = {
          enable = true;
          settings = {
            force_ft = "markdown";
            output_extension = "md";
            style = "markdown";
          };
        };

        molten = {
          enable = true;
          autoLoad = true;
          settings = {
            auto_open_output = false;
            wrap_output = true;
            virt_text_output = true;
            virt_lines_off_by_1 = true;
            output_win_max_height = 12;
            image_provider = "none";
          };
        };

        image = {
          enable = true;
          autoLoad = true;
          settings = {
            backend = config.sharedEditor.imageBackend;
            integrations = {
              markdown = {
                enabled = true;
                clear_in_insert_mode = false;
                download_remote_images = true;
                only_render_image_at_cursor = false;
              };
            };
            max_width = 100;
            max_height = 24;
            max_width_window_percentage = 100;
            max_height_window_percentage = 50;
            window_overlap_clear_enabled = true;
            window_overlap_clear_ft_ignore = [
              "cmp_menu"
              "cmp_docs"
              ""
            ];
          };
        };

        hydra = {
          enable = true;
          autoLoad = true;

          hydras = [
            {
              name = "notebook";
              mode = "n";
              body = "<localleader>j";

              config = {
                color = "pink";
                invoke_on_body = true;
              };

              hint = ''
                _j_: run cell         _l_: run line
                _a_: run above        _A_: run all
                _r_: re-eval cell     _o_: open output
                _h_: hide output      _x_: browser output
                _i_: molten init      _R_: restart kernel
                ^^                    _<esc>_/_q_: exit
              '';

              heads = [
                [
                  "j"
                  ''
                    function()
                      require("quarto.runner").run_cell()
                    end
                  ''
                  {
                    expr = false;
                  }
                ]
                [
                  "l"
                  ''
                    function()
                      require("quarto.runner").run_line()
                    end
                  ''
                  {
                    expr = false;
                  }
                ]
                [
                  "a"
                  ''
                    function()
                      require("quarto.runner").run_above()
                    end
                  ''
                  {
                    expr = false;
                  }
                ]
                [
                  "A"
                  ''
                    function()
                      require("quarto.runner").run_all()
                    end
                  ''
                  {
                    expr = false;
                  }
                ]
                [
                  "r"
                  "<cmd>MoltenReevaluateCell<cr>"
                ]
                [
                  "o"
                  "<cmd>noautocmd MoltenEnterOutput<cr>"
                ]
                [
                  "h"
                  "<cmd>MoltenHideOutput<cr>"
                ]
                [
                  "x"
                  "<cmd>MoltenOpenInBrowser<cr>"
                ]
                [
                  "i"
                  "<cmd>MoltenInit<cr>"
                ]
                [
                  "R"
                  "<cmd>MoltenRestart!<cr>"
                ]
                [
                  "<esc>"
                  null
                  { exit = true; }
                ]
                [
                  "q"
                  null
                  { exit = true; }
                ]
              ];
            }
          ];
        };

        which-key.settings.spec = [
          {
            __unkeyed-1 = "<localleader>m";
            group = "Molten";
          }
          {
            __unkeyed-1 = "<localleader>q";
            group = "Quarto";
          }
          {
            __unkeyed-1 = "<localleader>r";
            group = "Run";
          }
        ];
      };

      extraConfigLuaPre = ''
        require("kit.jupytext_safe").install()
        require("otter.config")
        OtterConfig = vim.tbl_deep_extend("force", OtterConfig or {}, {})
        vim.cmd("packadd molten-nvim")
        -- Force molten python path into PYTHONPATH
        local molten_paths = vim.api.nvim_get_runtime_file("rplugin/python3", true)

        for _, p in ipairs(molten_paths) do
          if p:match("molten%-nvim") then
            vim.env.PYTHONPATH = (vim.env.PYTHONPATH or "") .. ":" .. p
          end
        end
      '';

      extraConfigLua = ''
        vim.api.nvim_create_user_command("NewNotebook", function(opts)
          require("kit.notebook").create(opts.args)
        end, {
          nargs = 1,
          complete = "file",
        })

        vim.api.nvim_create_autocmd("FileType", {
          pattern = { "quarto", "markdown" },
          callback = function(args)
            local buf = args.buf
            local ft = vim.bo[buf].filetype

            ${lib.optionalString (config.sharedEditor.quartoSyncPackage != null) ''
              require("kit.quarto_sync").setup_buffer(buf)
            ''}

            if ft == "markdown" then
              pcall(function()
                require("quarto").activate()
              end)
            end

            local map = function(mode, lhs, rhs, desc)
              vim.keymap.set(mode, lhs, rhs, {
                buffer = buf,
                silent = true,
                desc = desc,
              })
            end

            vim.opt_local.wrap = true
            vim.opt_local.spell = true
            vim.opt_local.conceallevel = 2

            -- Molten kernel management
            map("n", "<localleader>mi", "<cmd>MoltenInit<cr>", "Molten init")
            map("n", "<localleader>mr", "<cmd>MoltenRestart!<cr>", "Molten restart kernel")
            map("n", "<localleader>mI", "<cmd>MoltenInterrupt<cr>", "Molten interrupt kernel")

            -- Quarto runner / notebook execution
            map("n", "<localleader>rc", function()
              require("quarto.runner").run_cell()
            end, "Run cell")

            map("n", "<localleader>ra", function()
              require("quarto.runner").run_above()
            end, "Run cell and above")

            map("n", "<localleader>rA", function()
              require("quarto.runner").run_all()
            end, "Run all cells")

            map("n", "<localleader>rl", function()
              require("quarto.runner").run_line()
            end, "Run line")

            map("v", "<localleader>r", function()
              require("quarto.runner").run_range()
            end, "Run visual range")

            -- Molten output controls
            map("n", "<localleader>me", "<cmd>noautocmd MoltenExportOutput<cr>", "Molten export output")
            map("n", "<localleader>mo", "<cmd>noautocmd MoltenEnterOutput<cr>", "Molten open output")
            map("n", "<localleader>mh", "<cmd>MoltenHideOutput<cr>", "Molten hide output")
            map("n", "<localleader>md", "<cmd>MoltenDelete<cr>", "Molten delete cell")
            map("n", "<localleader>mx", "<cmd>MoltenOpenInBrowser<cr>", "Molten open output in browser")

            -- Quarto document commands
            map("n", "<localleader>qp", "<cmd>QuartoPreview<cr>", "Quarto preview")
            map("n", "<localleader>qr", "<cmd>QuartoRender<cr>", "Quarto render")
          end,
        })
      '';

      keymaps = [
        {
          mode = "n";
          key = "<leader>qn";
          action = "<cmd>NewNotebook ";
          options.desc = "New notebook";
        }
        {
          mode = "n";
          key = "<leader>qp";
          action = "<cmd>QuartoPreview<cr>";
          options.desc = "Preview Quarto";
        }
        {
          mode = "n";
          key = "<leader>qr";
          action = "<cmd>QuartoRender<cr>";
          options.desc = "Render Quarto";
        }
        {
          mode = "n";
          key = "<leader>qc";
          action = "<cmd>QuartoClosePreview<cr>";
          options.desc = "Close Quarto preview";
        }
      ];

      autoCmd = [
        {
          event = "BufWritePost";
          pattern = [ "*.ipynb" ];
          callback.__raw = ''
            function()
              pcall(vim.cmd, "MoltenExportOutput")
            end
          '';
        }
        {
          event = "FileType";
          pattern = [
            "quarto"
            "markdown"
          ];
          callback.__raw = ''
            function()
              vim.opt_local.wrap = true
              vim.opt_local.spell = true
              vim.opt_local.conceallevel = 2
            end
          '';
        }
      ];
    };
  };
}

{
  config,
  pkgs,
  ...
}: let
  helpers = config.lib.nixvim;
in {
  programs.nixvim = {
    plugins = {
      quarto = {
        enable = true;
        settings = {
          lspFeatures = {
            enabled = true;
            chunks = "curly";
            languages = ["r" "python" "julia" "bash"];
            diagnostics = {
              enabled = true;
              triggers = ["BufWritePost"];
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

      molten = {
        enable = true;
        autoLoad = false;
        settings = {
          auto_open_output = false;
          wrap_output = true;
          virt_text_output = true;
          virt_lines_off_by_1 = true;
          output_win_max_height = 12;
          image_provider = "image.nvim";
        };
      };

      image = {
        enable = true;
        settings = {
          backend = "kitty";
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
          window_overlap_clear_ft_ignore = ["cmp_menu" "cmp_docs" ""];
        };
      };

      hydra = {
        enable = true;

        hydras = [
          {
            name = "notebook";
            mode = "n";
            body = "<localleader>j";

            config = {
              color = "pink";
              invoke_on_body = true;
              hint = {
              };
            };

            hint = ''
              _j_/_k_: move down/up   _e_: eval operator
              _r_: re-eval cell       _o_: open output
              _h_: hide output
              ^^      _<esc>_/_q_: exit
            '';

            heads = [
              ["j" "]b"]
              ["k" "[b"]
              ["e" "<cmd>MoltenEvaluateOperator<cr>"]
              ["r" "<cmd>MoltenReevaluateCell<cr>"]
              ["o" "<cmd>noautocmd MoltenEnterOutput<cr>"]
              ["h" "<cmd>MoltenHideOutput<cr>"]
              ["<esc>" null {exit = true;}]
              ["q" null {exit = true;}]
            ];
          }
        ];
      };
    };

    extraConfigLuaPre = ''
      require("otter.config")
      OtterConfig = vim.tbl_deep_extend("force", OtterConfig or {}, {})
    '';

    extraConfigLua = ''
      local default_notebook = [[
      {
        "cells": [
          {
            "cell_type": "markdown",
            "metadata": {},
            "source": [""]
          }
        ],
        "metadata": {
          "kernelspec": {
            "display_name": "Python 3",
            "language": "python",
            "name": "python3"
          },
          "language_info": {
            "codemirror_mode": { "name": "ipython" },
            "file_extension": ".py",
            "mimetype": "text/x-python",
            "name": "python",
            "nbconvert_exporter": "python",
            "pygments_lexer": "ipython3"
          }
        },
        "nbformat": 4,
        "nbformat_minor": 5
      }
      ]]

      local function new_notebook(filename)
        local path = filename .. ".ipynb"
        local file = io.open(path, "w")
        if file then
          file:write(default_notebook)
          file:close()
          vim.cmd("edit " .. path)
        else
          vim.notify("Could not create notebook: " .. path, vim.log.levels.ERROR)
        end
      end

      vim.api.nvim_create_user_command("NewNotebook", function(opts)
        new_notebook(opts.args)
      end, {
        nargs = 1,
        complete = "file",
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "quarto", "markdown" },
        callback = function(args)
          local buf = args.buf
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

          map("n", "]b", "]b", "Next code cell")
          map("n", "[b", "[b", "Previous code cell")

          map("n", "<localleader>mi", "<cmd>MoltenInit<cr>", "Molten init")
          map("n", "<localleader>mr", "<cmd>MoltenRestart!<cr>", "Molten restart kernel")
          map("n", "<localleader>mI", "<cmd>MoltenInterrupt<cr>", "Molten interrupt kernel")

          map("n", "<localleader>e", "<cmd>MoltenEvaluateOperator<cr>", "Molten evaluate operator")
          map("v", "<localleader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", "Molten evaluate visual")
          map("n", "<localleader>rr", "<cmd>MoltenReevaluateCell<cr>", "Molten re-evaluate cell")

          map("n", "<localleader>mo", "<cmd>noautocmd MoltenEnterOutput<cr>", "Molten open output")
          map("n", "<localleader>mh", "<cmd>MoltenHideOutput<cr>", "Molten hide output")
          map("n", "<localleader>md", "<cmd>MoltenDelete<cr>", "Molten delete cell")
          map("n", "<localleader>mx", "<cmd>MoltenOpenInBrowser<cr>", "Molten open output in browser")

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
        event = "FileType";
        pattern = ["quarto"];
        callback.__raw = ''
          function()
            vim.opt_local.wrap = true
            vim.opt_local.spell = true
            vim.opt_local.conceallevel = 2
          end
        '';
      }
    ];

    plugins.which-key.settings.spec = [
      {
        __unkeyed-1 = "<localleader>m";
        group = "Molten";
      }
      {
        __unkeyed-1 = "<localleader>q";
        group = "Quarto";
      }
    ];
  };
}

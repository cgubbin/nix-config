_: {
  flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-notebook" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      nixvim = config.programs.nixvim;
      # Molten is a Python remote plugin: Neovim only knows its commands from a
      # manifest written by :UpdateRemotePlugins. The Nixvim wrapper does not
      # generate one, so build it here instead of relying on a hand-made,
      # store-path-specific manifest in the user's data directory.
      moltenManifest =
        pkgs.runCommand "molten-rplugin-manifest"
          {
            nativeBuildInputs = [ pkgs.neovim-unwrapped ];
          }
          ''
            export HOME="$TMPDIR" XDG_DATA_HOME="$TMPDIR/data" XDG_STATE_HOME="$TMPDIR/state" XDG_CACHE_HOME="$TMPDIR/cache"
            export NVIM_RPLUGIN_MANIFEST="$out"
            nvim --headless -u NORC -i NONE \
              --cmd "let g:python3_host_prog = '${pkgs.python3.withPackages nixvim.extraPython3Packages}/bin/python3'" \
              --cmd "set runtimepath^=${nixvim.plugins.molten.package}" \
              +UpdateRemotePlugins +qa
            grep -q "MoltenInit" "$out"
          '';
    in
    {
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
              # Plots render through image.nvim, whose backend is the consumer's
              # sharedEditor.imageBackend; "both" puts them under the cell too.
              image_provider = "image.nvim";
              image_location = "both";
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
                  _j_: run + next   _c_: run cell     _l_: run line
                  _a_: run above    _A_: run all      _r_: re-evaluate
                  _n_: next cell    _p_: prev cell    _o_: open output
                  _h_: hide output  _d_: delete output _x_: browser
                  _i_: kernel       _k_: choose env   _I_: interrupt
                  _R_: restart      _e_: save outputs _L_: load saved
                  ^^                ^^                _<esc>_/_q_: exit
                '';

                heads =
                  let
                    # __raw: a plain string would be fed to Neovim as keystrokes.
                    cells = action: [
                      { __raw = ''function() require("kit.cells").${action} end''; }
                      { desc = action; }
                    ];
                  in
                  [
                    ([ "j" ] ++ cells "run_cell(0, true)")
                    ([ "c" ] ++ cells "run_cell(0, false)")
                    ([ "l" ] ++ cells "run_line(0)")
                    ([ "a" ] ++ cells "run_above(0)")
                    ([ "A" ] ++ cells "run_all(0)")
                    ([ "n" ] ++ cells "jump(0, 1)")
                    ([ "p" ] ++ cells "jump(0, -1)")
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
                      "d"
                      "<cmd>MoltenDelete<cr>"
                    ]
                    [
                      "x"
                      "<cmd>MoltenOpenInBrowser<cr>"
                    ]
                    [
                      "i"
                      "<cmd>NotebookKernel<cr>"
                    ]
                    [
                      "k"
                      "<cmd>NotebookKernelSelect<cr>"
                    ]
                    [
                      "I"
                      "<cmd>MoltenInterrupt<cr>"
                    ]
                    [
                      "R"
                      "<cmd>MoltenRestart!<cr>"
                    ]
                    [
                      "e"
                      { __raw = ''function() require("kit.kernel").export(0) end''; }
                      { desc = "export outputs"; }
                    ]
                    [
                      "L"
                      { __raw = ''function() require("kit.kernel").load_outputs(0) end''; }
                      { desc = "load saved outputs"; }
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
              __unkeyed-1 = "<localleader>r";
              group = "Run";
            }
          ];
        };

        extraConfigLuaPre = ''
          require("kit.jupytext_safe").install()
          require("otter.config")
          OtterConfig = vim.tbl_deep_extend("force", OtterConfig or {}, {})
          -- Read before plugin/rplugin.vim loads; replaces any stale user manifest.
          vim.env.NVIM_RPLUGIN_MANIFEST = "${moltenManifest}"
          -- Before Molten's host starts, so generated project kernelspecs are found.
          require("kit.kernel").setup()
        '';

        extraConfigLua = ''
          require("kit.kernel").commands()
          require("kit.render").commands()

          vim.api.nvim_create_user_command("NewNotebook", function(opts)
            require("kit.notebook").create(opts.args)
          end, {
            nargs = 1,
            complete = "file",
          })

          -- Everything else lives in the notebook Hydra (<localleader>j); only the
          -- hot paths get direct keys.
          local function notebook_keys(buf)
            local map = function(mode, lhs, rhs, desc)
              vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
            end
            map("n", "<localleader>rc", function() require("kit.cells").run_cell(0, false) end, "Run cell")
            map("n", "<localleader>mI", "<cmd>MoltenInterrupt<cr>", "Interrupt kernel")
            map("v", "<localleader>r", function()
              local first, last = vim.fn.line("v"), vim.fn.line(".")
              if first > last then first, last = last, first end
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", false)
              require("kit.cells").run_range(0, first, last)
            end, "Run selection")
          end

          vim.api.nvim_create_autocmd("FileType", {
            pattern = { "quarto", "markdown" },
            callback = function(args)
              local buf = args.buf
              ${lib.optionalString (config.sharedEditor.quartoSyncPackage != null) ''
                require("kit.quarto_sync").setup_buffer(buf)
              ''}
              if vim.bo[buf].filetype == "markdown" then
                pcall(function() require("quarto").activate() end)
              end
              notebook_keys(buf)
            end,
          })

          vim.api.nvim_create_autocmd("FileType", {
            pattern = "python",
            callback = function(args) notebook_keys(args.buf) end,
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
            action = "<cmd>NotebookRender<cr>";
            options.desc = "Render to a temporary page and open it";
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
            # Jupytext fires this after writing the cells; add the outputs.
            callback.__raw = ''
              function(args)
                require("kit.kernel").export(args.buf, vim.fn.fnamemodify(args.file, ":p"))
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

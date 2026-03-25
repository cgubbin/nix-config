{
  config,
  pkgs,
  ...
}: let
  helpers = config.lib.nixvim;
in {
  programs.nixvim = {
    plugins.treesitter = {
      enable = true;
      settings = {
        highlight = {
          enable = true;
          additional_vim_regex_highlighting = true;
        };
        indent.enable = true;

        ensure_installed = [
          "bash"
          "c"
          "cmake"
          "cpp"
          "csv"
          "fish"
          "json"
          "lua"
          "markdown"
          "markdown_inline"
          "nix"
          "python"
          "query"
          "regex"
          "rust"
          "sql"
          "toml"
          "typst"
          "vim"
          "yaml"
        ];

        incremental_selection = {
          enable = true;
          keymaps = {
            init_selection = "<C-space>";
            node_incremental = "<C-space>";
            scope_incremental = false;
            node_decremental = "<BS>";
          };
        };
      };
    };

    plugins.ts-autotag = {
      enable = true;
    };

    plugins.treesitter-context = {
      enable = true;
      autoLoad = true;
      settings = {
        max_lines = 4;
        multiline_threshold = 10;
        trim_scope = "outer";
      };
    };

    plugins.treesitter-textobjects = {
      enable = true;

      settings = {
        select = {
          enable = true;
          lookahead = true;
          keymaps = {
            "a=" = {
              query = "@assignment.outer";
              desc = "Select outer part of an assignment";
            };
            "i=" = {
              query = "@assignment.inner";
              desc = "Select inner part of an assignment";
            };
            "l=" = {
              query = "@assignment.lhs";
              desc = "Select left hand side of an assignment";
            };
            "r=" = {
              query = "@assignment.rhs";
              desc = "Select right hand side of an assignment";
            };

            "a:" = {
              query = "@property.outer";
              desc = "Select outer part of an object property";
            };
            "i:" = {
              query = "@property.inner";
              desc = "Select inner part of an object property";
            };
            "l:" = {
              query = "@property.lhs";
              desc = "Select left part of an object property";
            };
            "r:" = {
              query = "@property.rhs";
              desc = "Select right part of an object property";
            };

            "aa" = {
              query = "@parameter.outer";
              desc = "Select outer part of a parameter/argument";
            };
            "ia" = {
              query = "@parameter.inner";
              desc = "Select inner part of a parameter/argument";
            };

            "ai" = {
              query = "@conditional.outer";
              desc = "Select outer part of a conditional";
            };
            "ii" = {
              query = "@conditional.inner";
              desc = "Select inner part of a conditional";
            };

            "al" = {
              query = "@loop.outer";
              desc = "Select outer part of a loop";
            };
            "il" = {
              query = "@loop.inner";
              desc = "Select inner part of a loop";
            };

            "af" = {
              query = "@call.outer";
              desc = "Select outer part of a function call";
            };
            "if" = {
              query = "@call.inner";
              desc = "Select inner part of a function call";
            };

            "am" = {
              query = "@function.outer";
              desc = "Select outer part of a method/function definition";
            };
            "im" = {
              query = "@function.inner";
              desc = "Select inner part of a method/function definition";
            };

            "ac" = {
              query = "@class.outer";
              desc = "Select outer part of a class";
            };
            "ic" = {
              query = "@class.inner";
              desc = "Select inner part of a class";
            };

            "ib" = {
              query = "@code_cell.inner";
              desc = "in block";
            };
            "ab" = {
              query = "@code_cell.outer";
              desc = "around block";
            };
          };
        };

        swap = {
          enable = true;
          swap_next = {
            "<leader>na" = "@parameter.inner";
            "<leader>n:" = "@property.outer";
            "<leader>nm" = "@function.outer";
            "<leader>sbl" = "@code_cell.outer";
          };
          swap_previous = {
            "<leader>pa" = "@parameter.inner";
            "<leader>p:" = "@property.outer";
            "<leader>pm" = "@function.outer";
            "<leader>sbh" = "@code_cell.outer";
          };
        };

        move = {
          enable = true;
          set_jumps = true;

          goto_next_start = {
            "]f" = {
              query = "@call.outer";
              desc = "Next function call start";
            };
            "]m" = {
              query = "@function.outer";
              desc = "Next method/function def start";
            };
            "]c" = {
              query = "@class.outer";
              desc = "Next class start";
            };
            "]i" = {
              query = "@conditional.outer";
              desc = "Next conditional start";
            };
            "]l" = {
              query = "@loop.outer";
              desc = "Next loop start";
            };
            "]s" = {
              query = "@scope";
              query_group = "locals";
              desc = "Next scope";
            };
            "]z" = {
              query = "@fold";
              query_group = "folds";
              desc = "Next fold";
            };
            "]b" = {
              query = "@code_cell.inner";
              desc = "Next code block";
            };
          };

          goto_next_end = {
            "]F" = {
              query = "@call.outer";
              desc = "Next function call end";
            };
            "]M" = {
              query = "@function.outer";
              desc = "Next method/function def end";
            };
            "]C" = {
              query = "@class.outer";
              desc = "Next class end";
            };
            "]I" = {
              query = "@conditional.outer";
              desc = "Next conditional end";
            };
            "]L" = {
              query = "@loop.outer";
              desc = "Next loop end";
            };
          };

          goto_previous_start = {
            "[f" = {
              query = "@call.outer";
              desc = "Prev function call start";
            };
            "[m" = {
              query = "@function.outer";
              desc = "Prev method/function def start";
            };
            "[c" = {
              query = "@class.outer";
              desc = "Prev class start";
            };
            "[i" = {
              query = "@conditional.outer";
              desc = "Prev conditional start";
            };
            "[l" = {
              query = "@loop.outer";
              desc = "Prev loop start";
            };
            "[b" = {
              query = "@code_cell.inner";
              desc = "Previous code block";
            };
          };

          goto_previous_end = {
            "[F" = {
              query = "@call.outer";
              desc = "Prev function call end";
            };
            "[M" = {
              query = "@function.outer";
              desc = "Prev method/function def end";
            };
            "[C" = {
              query = "@class.outer";
              desc = "Prev class end";
            };
            "[I" = {
              query = "@conditional.outer";
              desc = "Prev conditional end";
            };
            "[L" = {
              query = "@loop.outer";
              desc = "Prev loop end";
            };
          };
        };
      };
    };

    keymaps = [
      {
        mode = ["n" "x" "o"];
        key = ";";
        action = helpers.mkRaw ''
          function()
            require("nvim-treesitter.textobjects.repeatable_move").repeat_last_move()
          end
        '';
      }
      {
        mode = ["n" "x" "o"];
        key = ",";
        action = helpers.mkRaw ''
          function()
            require("nvim-treesitter.textobjects.repeatable_move").repeat_last_move_opposite()
          end
        '';
      }
      {
        mode = ["n" "x" "o"];
        key = "f";
        action = helpers.mkRaw ''
          function()
            require("nvim-treesitter.textobjects.repeatable_move").builtin_f()
          end
        '';
      }
      {
        mode = ["n" "x" "o"];
        key = "F";
        action = helpers.mkRaw ''
          function()
            require("nvim-treesitter.textobjects.repeatable_move").builtin_F()
          end
        '';
      }
      {
        mode = ["n" "x" "o"];
        key = "t";
        action = helpers.mkRaw ''
          function()
            require("nvim-treesitter.textobjects.repeatable_move").builtin_t()
          end
        '';
      }
      {
        mode = ["n" "x" "o"];
        key = "T";
        action = helpers.mkRaw ''
          function()
            require("nvim-treesitter.textobjects.repeatable_move").builtin_T()
          end
        '';
      }
      {
        mode = "n";
        key = "<leader>ucx";
        action = "<cmd>TSContextToggle<cr>";
        options.desc = "Toggle Treesitter Context";
      }
    ];
    plugins.which-key.settings.spec = [
      {
        __unkeyed-1 = "<leader>u";
        group = "UI / Toggles";
      }
    ];
  };
}

{
  config,
  pkgs,
  ...
}: let
  helpers = config.lib.nixvim;
in {
  programs.nixvim = {
    plugins.dap = {
      enable = true;
      autoLoad = true;

      configurations = {
        rust = [
          {
            name = "Launch";
            type = "lldb";
            request = "launch";
            program = helpers.mkRaw ''
              function()
                return vim.fn.input(
                  "Path to executable: ",
                  vim.fn.getcwd() .. "/target/debug/",
                  "file"
                )
              end
            '';
            cwd = "\${workspaceFolder}";
            stopOnEntry = false;
            initCommands = helpers.mkRaw ''
              function()
                local rustc_sysroot = vim.fn.trim(vim.fn.system("rustc --print sysroot"))

                local script_import =
                  'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
                local commands_file = rustc_sysroot .. "/lib/rustlib/etc/lldb_commands"

                local commands = {}
                local file = io.open(commands_file, "r")
                if file then
                  for line in file:lines() do
                    table.insert(commands, line)
                  end
                  file:close()
                end
                table.insert(commands, 1, script_import)

                return commands
              end
            '';
          }
        ];

        c = [
          {
            name = "Launch";
            type = "lldb";
            request = "launch";
            program = helpers.mkRaw ''
              function()
                return vim.fn.input(
                  "Path to executable: ",
                  vim.fn.getcwd() .. "/",
                  "file"
                )
              end
            '';
            cwd = "\${workspaceFolder}";
            stopOnEntry = true;
            args = [];
          }
        ];

        cpp = [
          {
            name = "Launch";
            type = "lldb";
            request = "launch";
            program = helpers.mkRaw ''
              function()
                return vim.fn.input(
                  "Path to executable: ",
                  vim.fn.getcwd() .. "/",
                  "file"
                )
              end
            '';
            cwd = "\${workspaceFolder}";
            stopOnEntry = true;
            args = [];
          }
        ];
      };
    };

    extraPlugins = with pkgs.vimPlugins; [
      nvim-dap-ui
      nvim-nio
    ];

    extraPackages = with pkgs; [
      lldb
      gdb
      rustc
    ];

    extraConfigLua = ''
      local dap = require("dap")
      local dapui = require("dapui")

      dap.set_log_level("INFO")

      dap.adapters.gdb = {
        type = "executable",
        command = vim.fn.exepath("gdb"),
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
      }

      dap.adapters.lldb = {
        type = "executable",
        command = vim.fn.exepath("lldb-dap"),
        name = "lldb",
      }

      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸" },
        mappings = {
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        expand_lines = vim.fn.has("nvim-0.7") == 1,
        layouts = {
          {
            elements = { "scopes" },
            size = 0.3,
            position = "right",
          },
          {
            elements = { "repl", "breakpoints" },
            size = 0.3,
            position = "bottom",
          },
        },
        floating = {
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil,
        },
      })

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "Error" })
    '';

    keymaps = [
      {
        mode = "n";
        key = "<leader>ds";
        action = helpers.mkRaw ''
          function()
            require("dap").continue()
            require("dapui").toggle({})
            vim.api.nvim_feedkeys(
              vim.api.nvim_replace_termcodes("<C-w>=", false, true, true),
              "n",
              false
            )
          end
        '';
        options.desc = "Debug start / continue";
      }
      {
        mode = "n";
        key = "<leader>dl";
        action = helpers.mkRaw ''
          function()
            require("dap.ui.widgets").hover()
          end
        '';
        options.desc = "Debug hover";
      }
      {
        mode = "n";
        key = "<leader>dc";
        action = helpers.mkRaw ''
          function()
            require("dap").continue()
          end
        '';
        options.desc = "Debug continue";
      }
      {
        mode = "n";
        key = "<leader>db";
        action = helpers.mkRaw ''
          function()
            require("dap").toggle_breakpoint()
          end
        '';
        options.desc = "Toggle breakpoint";
      }
      {
        mode = "n";
        key = "<leader>dn";
        action = helpers.mkRaw ''
          function()
            require("dap").step_over()
          end
        '';
        options.desc = "Step over";
      }
      {
        mode = "n";
        key = "<leader>di";
        action = helpers.mkRaw ''
          function()
            require("dap").step_into()
          end
        '';
        options.desc = "Step into";
      }
      {
        mode = "n";
        key = "<leader>do";
        action = helpers.mkRaw ''
          function()
            require("dap").step_out()
          end
        '';
        options.desc = "Step out";
      }
      {
        mode = "n";
        key = "<leader>dC";
        action = helpers.mkRaw ''
          function()
            require("dap").clear_breakpoints()
            vim.notify("Breakpoints cleared", vim.log.levels.WARN, { title = "DAP" })
          end
        '';
        options.desc = "Clear breakpoints";
      }
      {
        mode = "n";
        key = "<leader>de";
        action = helpers.mkRaw ''
          function()
            require("dap").clear_breakpoints()
            require("dapui").toggle({})
            require("dap").terminate()
            vim.api.nvim_feedkeys(
              vim.api.nvim_replace_termcodes("<C-w>=", false, true, true),
              "n",
              false
            )
          end
        '';
        options.desc = "End debug session";
      }
    ];

    plugins.which-key.settings.spec = [
      {
        __unkeyed-1 = "<leader>d";
        group = "Debug";
      }
    ];
  };
}

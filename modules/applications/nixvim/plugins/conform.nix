_: {
  flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-conform" =
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
        plugins.conform-nvim = {
          enable = true;

          settings = {
            default_format_opts = {
              lsp_format = "fallback";
            };

            format_on_save = {
              timeout_ms = 500;
              lsp_format = "fallback";
            };

            formatters = {
              ruff_format = {
                command = "direnv";
                prepend_args = helpers.mkRaw ''
                  function(_, ctx)
                    local project = require("kit.project")
                    local root = project.root(vim.api.nvim_buf_get_name(ctx.buf))
                    local command = project.command(root, { project.python_tool(root, "ruff") }, "ruff")
                    table.remove(command, 1)
                    return command
                  end
                '';
              };
              typstyle = {
                command = "${pkgs.typstyle}/bin/typstyle";
                args = [
                  "-i"
                  "-t"
                  "2"
                  "$FILENAME"
                ];
                stdin = false;
              };

              sql-formatter = {
                command = "${pkgs.sql-formatter}/bin/sql-formatter";
                args = [
                  "--fix"
                  "$FILENAME"
                ];
                stdin = false;
              };

              kdl = {
                command = "${pkgs.kdlfmt}/bin/kdlfmt";
                args = [
                  "format"
                  "$FILENAME"
                ];
                stdin = false;
              };

              injected = {
                ignore_errors = false;
              };
            };

            formatters_by_ft = {
              markdown = [ "injected" ];
              rust = [ "rustfmt" ];
              nix = [ "alejandra" ];
              typst = [ "typstyle" ];
              sh = [ "shfmt" ];
              sql = [ "sql-formatter" ];
              kdl = [ "kdl" ];
              json = [ "jq" ];
              quarto = [ "injected" ];
              python = [ "ruff_format" ];
              yaml = [ "prettier" ];
              lua = [ "stylua" ];
            };
          };
        };

        keymaps = [
          {
            mode = [
              "n"
              "v"
            ];
            key = "<M-S-f>";
            action = helpers.mkRaw ''
              function()
                require("conform").format({ async = true, lsp_format = "fallback" })
              end
            '';
            options.desc = "Format buffer or range";
          }
        ];
      };
    };
}

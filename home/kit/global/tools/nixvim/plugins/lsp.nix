{
  config,
  pkgs,
  ...
}: let
  helpers = config.lib.nixvim;
in {
  programs.nixvim = {
    plugins = {
      lsp = {
        enable = true;

        inlayHints = true;

        servers = {
          nixd = {
            enable = true;
          };

          lua_ls = {
            enable = true;
            settings = {
              Lua = {
                diagnostics = {
                  globals = ["vim" "Snacks" "OtterConfig"];
                };
                workspace = {
                  checkThirdParty = false;
                };
                telemetry = {
                  enable = false;
                };
              };
            };
          };

          ruff = {
            enable = true;
          };

          pyright = {
            enable = true;
          };

          bashls.enable = true;
          jsonls.enable = true;
          yamlls.enable = true;
          clangd.enable = true;
          cmake.enable = true;
        };
      };

      cmp = {
        enable = true;
        autoLoad = true;
        autoEnableSources = true;
        settings.sources = [
          {name = "nvim_lsp";}
          {name = "path";}
          {name = "buffer";}
          {name = "luasnip";}
        ];
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "gd";
        action = helpers.mkRaw ''function() vim.lsp.buf.definition() end'';
        options.desc = "Go to definition";
      }
      {
        mode = "n";
        key = "gD";
        action = helpers.mkRaw ''function() vim.lsp.buf.declaration() end'';
        options.desc = "Go to declaration";
      }
      {
        mode = "n";
        key = "gr";
        action = helpers.mkRaw ''function() vim.lsp.buf.references() end'';
        options.desc = "References";
      }
      {
        mode = "n";
        key = "gi";
        action = helpers.mkRaw ''function() vim.lsp.buf.implementation() end'';
        options.desc = "Implementation";
      }
      {
        mode = "n";
        key = "K";
        action = helpers.mkRaw ''function() vim.lsp.buf.hover() end'';
        options.desc = "Hover";
      }
      {
        mode = "n";
        key = "<leader>cr";
        action = helpers.mkRaw ''function() vim.lsp.buf.rename() end'';
        options.desc = "Rename symbol";
      }
      {
        mode = ["n" "v"];
        key = "<leader>ca";
        action = helpers.mkRaw ''function() vim.lsp.buf.code_action() end'';
        options.desc = "Code action";
      }
      {
        mode = "n";
        key = "<leader>cf";
        action = helpers.mkRaw ''
          function()
            vim.lsp.buf.format({ async = true })
          end
        '';
        options.desc = "LSP format";
      }
      {
        mode = "n";
        key = "[d";
        action = helpers.mkRaw ''function() vim.diagnostic.goto_prev() end'';
        options.desc = "Previous diagnostic";
      }
      {
        mode = "n";
        key = "]d";
        action = helpers.mkRaw ''function() vim.diagnostic.goto_next() end'';
        options.desc = "Next diagnostic";
      }
      {
        mode = "n";
        key = "<leader>cd";
        action = helpers.mkRaw ''function() vim.diagnostic.open_float() end'';
        options.desc = "Line diagnostics";
      }
    ];
  };
}

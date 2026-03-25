{
  config,
  pkgs,
  ...
}: let
  helpers = config.lib.nixvim;
in {
  programs.nixvim = {
    opts.completeopt = ["menu" "menuone" "noselect"];

    plugins = {
      luasnip = {
        enable = true;
        settings = {
          enable_autosnippets = true;
        };
      };

      friendly-snippets.enable = true;

      lspkind = {
        enable = true;
        cmp = {
          enable = true;
        };
        settings.cmp.menu = {
          nvim_lsp = "[LSP]";
          nvim_lua = "[api]";
          path = "[path]";
          luasnip = "[snip]";
          buffer = "[buffer]";
          neorg = "[neorg]";
          cmp_tabby = "[tabby]";
        };
      };

      cmp = {
        enable = true;
        autoLoad = true;
        autoEnableSources = true;

        settings = {
          snippet.expand = helpers.mkRaw ''
            function(args)
              require("luasnip").lsp_expand(args.body)
            end
          '';

          mapping = {
            "<C-k>" = helpers.mkRaw "require('cmp').mapping.select_prev_item()";
            "<C-j>" = helpers.mkRaw "require('cmp').mapping.select_next_item()";
            "<C-b>" = helpers.mkRaw "require('cmp').mapping.scroll_docs(-4)";
            "<C-f>" = helpers.mkRaw "require('cmp').mapping.scroll_docs(4)";
            "<C-Space>" = helpers.mkRaw "require('cmp').mapping.complete()";
            "<C-e>" = helpers.mkRaw "require('cmp').mapping.abort()";
            "<CR>" = helpers.mkRaw "require('cmp').mapping.confirm({ select = false })";
          };

          sources = [
            {
              name = "luasnip";
              option = {
                use_show_condition = true;
                show_autosnippets = true;
              };
            }
            {name = "nvim_lsp";}
            {name = "path";}
            {
              name = "buffer";
              option.get_bufnrs = helpers.mkRaw "vim.api.nvim_list_bufs";
            }

            # Keep these only if you actually have the matching source plugins enabled elsewhere.
            {name = "cmp_tabby";}
            {name = "neorg";}
          ];
        };
      };

      cmp-buffer.enable = true;
      cmp-path.enable = true;
      cmp_luasnip.enable = true;
      cmp-nvim-lsp.enable = true;
    };

    keymaps = [
      {
        mode = ["i" "s"];
        key = "<C-l>";
        action = helpers.mkRaw ''
          function()
            local luasnip = require("luasnip")
            if luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            end
          end
        '';
      }
      {
        mode = ["i" "s"];
        key = "<C-h>";
        action = helpers.mkRaw ''
          function()
            local luasnip = require("luasnip")
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            end
          end
        '';
      }
    ];

    extraConfigLua = ''
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_lua").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/LuaSnip" }
      })
    '';
  };
}

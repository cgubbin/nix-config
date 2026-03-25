{
  config,
  pkgs,
  ...
}: let
  helpers = config.lib.nixvim;
in {
  programs.nixvim = {
    plugins.rustaceanvim = {
      enable = true;
      lazyLoad = {
        enable = true;
        settings.ft = ["rust"];
      };
      settings = {
        server = {
          cmd = [
            "rustup"
            "run"
            "nightly"
            "rust-analyzer"
          ];
          on_attach = helpers.mkRaw ''
                function(client, bufnr)
                    vim.keymap.set("n", "<leader>ra", function()
                        vim.cmd.RustLsp("codeAction")
                end, { desc = "Rust Code Action", buffer = bufnr })

                vim.keymap.set("n", "<leader>rd", function()
                    vim.cmd.RustLsp("debuggables")
                end, { desc = "Rust Debuggables", buffer = bufnr })

                client.server_capabilities.workspace.didChangeWatchedFiles = {
                    dynamicRegistration = true,
                    relativePatternSupport = false,
                }
            end
          '';
          default_settings = {
            rust-analyzer = {
              check = {
                command = "clippy";
              };
              files = {
                excludeDirs = [
                  ".cargo"
                  ".direnv"
                  ".git"
                  "target"
                ];
              };
              inlayHints = {
                lifetimeElisionHints = {
                  enable = "always";
                };
              };
            };
          };
          standalone = false;
        };
      };
    };
  };
}

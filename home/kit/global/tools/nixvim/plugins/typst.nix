{ pkgs, ... }:
{
  programs.nixvim = {
    plugins = {
      typst-vim = {
        enable = true;
        autoLoad = true;
      };

      lsp = {
        enable = true;

        servers.tinymist = {
          enable = true;

          settings = {
            exportPdf = "onSave";
            formatterMode = "typstyle";
            semanticTokens = "enable";
          };
        };
      };
    };

    extraPackages = with pkgs; [
      typst
    ];

    keymaps = [
      {
        mode = "n";
        key = "<leader>tp";
        action = "<cmd>LspTinymistExportPdf<cr>";
        options.desc = "Export Typst PDF";
      }
    ];
  };
}

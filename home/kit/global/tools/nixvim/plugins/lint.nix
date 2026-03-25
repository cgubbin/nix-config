{
  config,
  pkgs,
  ...
}: let
  helpers = config.lib.nixvim;
in {
  programs.nixvim = {
    plugins.lint = {
      enable = true;

      lintersByFt = {
        python = ["ruff"];
        yaml = ["yamllint"];
        sql = ["sqlfluff"];
      };
    };
    extraPackages = with pkgs; [
      yamllint
      ruff
      sqlfluff
    ];

    autoCmd = [
      {
        event = ["BufWritePost" "InsertLeave"];
        callback.__raw = ''
          function()
            require("lint").try_lint()
          end
        '';
      }
    ];

    keymaps = [
      {
        mode = "n";
        key = "<leader>l";
        action = helpers.mkRaw ''
          function()
            require("lint").try_lint()
          end
        '';
        options.desc = "Lint current file";
      }
    ];
  };
}

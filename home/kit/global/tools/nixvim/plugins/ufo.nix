{
  config,
  pkgs,
  ...
}: let
  helpers = config.lib.nixvim;
in {
  programs.nixvim = {
    plugins.nvim-ufo = {
      enable = true;
      autoLoad = true;
      setupLspCapabilities = true;
      settings = {
        open_fold_hl_timeout = 150;
        close_fold_kinds_for_ft = {
          default = ["imports" "comment"];
          json = ["array"];
          c = ["comment" "region"];
          cpp = ["comment" "region"];
        };
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "zR";
        action = helpers.mkRaw ''function() require("ufo").openAllFolds() end'';
        options.desc = "Open all folds";
      }
      {
        mode = "n";
        key = "zM";
        action = helpers.mkRaw ''function() require("ufo").closeAllFolds() end'';
        options.desc = "Close all folds";
      }
      {
        mode = "n";
        key = "zr";
        action = helpers.mkRaw ''function() require("ufo").openFoldsExceptKinds() end'';
        options.desc = "Open folds except kinds";
      }
      {
        mode = "n";
        key = "zm";
        action = helpers.mkRaw ''function() require("ufo").closeFoldsWith() end'';
        options.desc = "Close folds with";
      }
    ];
    opts = {
      foldcolumn = "1";
      foldlevel = 99;
      foldlevelstart = 99;
      foldenable = true;
    };
  };
}

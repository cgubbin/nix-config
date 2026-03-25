{
  config,
  pkgs,
  ...
}: let
  helpers = config.lib.nixvim;
in {
  programs.nixvim = {
    plugins.persistence = {
      enable = true;
      autoLoad = true;
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>qs";
        action = helpers.mkRaw ''function() require("persistence").load() end'';
        options.desc = "Restore session";
      }
      {
        mode = "n";
        key = "<leader>qS";
        action = helpers.mkRaw ''function() require("persistence").select() end'';
        options.desc = "Select session";
      }
      {
        mode = "n";
        key = "<leader>ql";
        action = helpers.mkRaw ''function() require("persistence").load({ last = true }) end'';
        options.desc = "Restore last session";
      }
      {
        mode = "n";
        key = "<leader>qd";
        action = helpers.mkRaw ''function() require("persistence").stop() end'';
        options.desc = "Stop session save";
      }
    ];
    plugins.which-key.settings.spec = [
      {
        __unkeyed-1 = "<leader>q";
        group = "Session";
      }
    ];
  };
}

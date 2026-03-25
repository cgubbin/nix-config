{ config, pkgs, ... }:

let
  helpers = config.lib.nixvim;
in
{
  programs.nixvim.plugins.harpoon = {
    enable = true;
    enableTelescope = true;

    settings = {
     settings = {
      save_on_toggle = true;
      sync_on_ui_close = true;
            };
    };
  };

  programs.nixvim.keymaps = [
    # Add file
    {
      mode = "n";
      key = "<leader>ha";
      action = helpers.mkRaw ''
        function() require("harpoon.mark").add_file() end
      '';
      options.desc = "Harpoon add file";
    }

    # Toggle quick menu
    {
      mode = "n";
      key = "<leader>hh";
      action = helpers.mkRaw ''
        function() require("harpoon.ui").toggle_quick_menu() end
      '';
      options.desc = "Harpoon menu";
    }

    # Jump directly
    {
      mode = "n";
      key = "<leader>1";
      action = helpers.mkRaw ''
        function() require("harpoon.ui").nav_file(1) end
      '';
    }
    {
      mode = "n";
      key = "<leader>2";
      action = helpers.mkRaw ''
        function() require("harpoon.ui").nav_file(2) end
      '';
    }
    {
      mode = "n";
      key = "<leader>3";
      action = helpers.mkRaw ''
        function() require("harpoon.ui").nav_file(3) end
      '';
    }
    {
      mode = "n";
      key = "<leader>4";
      action = helpers.mkRaw ''
        function() require("harpoon.ui").nav_file(4) end
      '';
    }
    {
      mode = "n";
      key = "<leader>hn";
      action = helpers.mkRaw ''
        function() require("harpoon.ui").nav_next() end
      '';
      options.desc = "Harpoon next";
    }
    {
      mode = "n";
      key = "<leader>hp";
      action = helpers.mkRaw ''
        function() require("harpoon.ui").nav_prev() end
      '';
      options.desc = "Harpoon prev";
    }
    {
        key = "<leader>hf";
        action = "<cmd>Telescope harpoon marks<cr>";
        options.desc = "Harpoon via Telescope";
    }
  ];
}

_: {
  flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-harpoon" =
    {
      config,
      ...
    }:
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
            function() require("harpoon"):list():add() end
          '';
          options.desc = "Harpoon add file";
        }

        # Toggle quick menu
        {
          mode = "n";
          key = "<leader>hh";
          action = helpers.mkRaw ''
            function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end
          '';
          options.desc = "Harpoon menu";
        }

        # Jump directly
        {
          mode = "n";
          key = "<leader>1";
          action = helpers.mkRaw ''
            function() require("harpoon"):list():select(1) end
          '';
          options.desc = "Harpoon mark 1";
        }
        {
          mode = "n";
          key = "<leader>2";
          action = helpers.mkRaw ''
            function() require("harpoon"):list():select(2) end
          '';
          options.desc = "Harpoon mark 2";
        }
        {
          mode = "n";
          key = "<leader>3";
          action = helpers.mkRaw ''
            function() require("harpoon"):list():select(3) end
          '';
          options.desc = "Harpoon mark 3";
        }
        {
          mode = "n";
          key = "<leader>4";
          action = helpers.mkRaw ''
            function() require("harpoon"):list():select(4) end
          '';
          options.desc = "Harpoon mark 4";
        }
        {
          mode = "n";
          key = "<leader>hn";
          action = helpers.mkRaw ''
            function() require("harpoon"):list():next() end
          '';
          options.desc = "Harpoon next";
        }
        {
          mode = "n";
          key = "<leader>hp";
          action = helpers.mkRaw ''
            function() require("harpoon"):list():prev() end
          '';
          options.desc = "Harpoon prev";
        }
        {
          key = "<leader>hf";
          action = "<cmd>Telescope harpoon marks<cr>";
          options.desc = "Harpoon via Telescope";
        }
      ];
    };
}

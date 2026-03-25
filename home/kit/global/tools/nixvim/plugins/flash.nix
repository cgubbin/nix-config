{ config, pkgs, ... }:

let
  helpers = config.lib.nixvim;
in
{
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [
      flash-nvim
    ];

    extraConfigLua = ''
      require("flash").setup({
        labels = "asdfghjklqwertyuiopzxcvbnm",
        search = {
          multi_window = false,
        },
        jump = {
          autojump = false,
        },
        modes = {
          char = {
            enabled = true,
            keys = { "f", "F", "t", "T", ";", "," },
          },
        },
      })
    '';

    keymaps = [
      {
        mode = [ "n" "x" "o" ];
        key = "s";
        action = helpers.mkRaw ''
          function() require("flash").jump() end
        '';
        options.desc = "Flash";
      }
      {
        mode = [ "n" "x" "o" ];
        key = "S";
        action = helpers.mkRaw ''
          function() require("flash").treesitter() end
        '';
        options.desc = "Flash Treesitter";
      }
      {
        mode = "o";
        key = "r";
        action = helpers.mkRaw ''
          function() require("flash").remote() end
        '';
        options.desc = "Remote Flash";
      }
      {
        mode = [ "o" "x" ];
        key = "R";
        action = helpers.mkRaw ''
          function() require("flash").treesitter_search() end
        '';
        options.desc = "Treesitter Search";
      }
      {
        mode = "c";
        key = "<C-s>";
        action = helpers.mkRaw ''
          function() require("flash").toggle() end
        '';
        options.desc = "Toggle Flash Search";
      }
    ];
  };
}

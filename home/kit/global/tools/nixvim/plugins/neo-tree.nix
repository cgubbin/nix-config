{ ... }:
{
  programs.nixvim.plugins.neo-tree = {
    enable = true;

    settings = {
      close_if_last_window = true;
      filesystem = {
        follow_current_file = {
          enabled = true;
          leave_dirs_open = false;
        };
        hijack_netrw_behavior = "open_default";
        use_libuv_file_watcher = true;
      };
      window = {
        width = 32;
        mappings = {
          "<space>" = "none";
          "l" = "open";
          "h" = "close_node";
          "<cr>" = "open";
          "o" = "open";
          "P" = { command = "toggle_preview"; config = { use_float = true; }; };
          "R" = "refresh";
          "Y" = "copy_path";
          "/" = "filter_as_you_type";
          "H" = "toggle_hidden";
        };
      };
    };
  };

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>e";
      action = "<cmd>Neotree toggle filesystem left<cr>";
      options.desc = "Explorer";
    }
    {
      mode = "n";
      key = "<leader>fe";
      action = "<cmd>Neotree reveal filesystem left<cr>";
      options.desc = "Reveal file in explorer";
    }
    {
      mode = "n";
      key = "<leader>be";
      action = "<cmd>Neotree show buffers right<cr>";
      options.desc = "Buffer explorer";
    }
    {
      mode = "n";
      key = "<leader>ge";
      action = "<cmd>Neotree float git_status<cr>";
      options.desc = "Git explorer";
    }
  ];
}

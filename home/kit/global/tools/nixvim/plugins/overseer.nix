{ ... }:
{
  programs.nixvim = {
    plugins.overseer = {
      enable = true;

      settings = {
        strategy = "toggleterm";
        dap = false;

        task_list = {
          direction = "right";
          min_width = 40;
          max_width = 80;
          default_detail = 1;
        };

        form = {
          border = "rounded";
        };

        confirm = {
          border = "rounded";
        };

        task_win = {
          border = "rounded";
        };
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>or";
        action = "<cmd>OverseerRun<cr>";
        options.desc = "Run task";
      }
      {
        mode = "n";
        key = "<leader>ot";
        action = "<cmd>OverseerToggle<cr>";
        options.desc = "Toggle task list";
      }
      {
        mode = "n";
        key = "<leader>oa";
        action = "<cmd>OverseerTaskAction<cr>";
        options.desc = "Task action";
      }
      {
        mode = "n";
        key = "<leader>oi";
        action = "<cmd>OverseerInfo<cr>";
        options.desc = "Overseer info";
      }
    ];
  };
}

{...}: {
  programs.nixvim = {
    plugins.zellij-nav.enable = true;

    keymaps = [
      {
        mode = "n";
        key = "<C-h>";
        action = "<cmd>ZellijNavigateLeft<cr>";
        options.desc = "Left split/pane";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<cmd>ZellijNavigateDown<cr>";
        options.desc = "Down split/pane";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<cmd>ZellijNavigateUp<cr>";
        options.desc = "Up split/pane";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<cmd>ZellijNavigateRight<cr>";
        options.desc = "Right split/pane";
      }
    ];
  };
}

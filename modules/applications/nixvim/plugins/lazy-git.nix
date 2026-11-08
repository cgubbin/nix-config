_: {
  flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-lazy-git" = { pkgs, ... }: {
    programs.nixvim = {
      plugins.lazygit = {
        enable = true;
      };

      extraPackages = with pkgs; [
        lazygit
      ];

      keymaps = [
        {
          mode = "n";
          key = "<leader>gg";
          action = "<cmd>LazyGit<cr>";
          options.desc = "Lazygit";
        }
      ];
    };

  };
}

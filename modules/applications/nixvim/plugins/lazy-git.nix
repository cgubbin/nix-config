_: {
  flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-lazy-git" = { pkgs, ... }: {
    programs.nixvim = {
      plugins.lazygit = {
        enable = true;
      };

      extraPackages = with pkgs; [
        lazygit
      ];

    };

  };
}

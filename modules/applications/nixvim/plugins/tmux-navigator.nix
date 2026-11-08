_: {
  flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-tmux-navigator" = {
    programs.nixvim.plugins.tmux-navigator = {
      enable = true;
    };
  };
}

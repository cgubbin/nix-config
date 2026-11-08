_: {
  flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-surround" = _: {
    programs.nixvim = {
      plugins.nvim-surround = {
        enable = true;
      };
    };
  };
}

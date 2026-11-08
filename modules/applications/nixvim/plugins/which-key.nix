_: {
  flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-which-key" = _: {
    programs.nixvim = {
      opts = {
        timeout = true;
        #     timeoutlen = 300;
      };
      plugins.which-key = {
        enable = true;
        settings = { };
      };
    };
  };
}

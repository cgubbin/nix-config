_: {
  flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-wrapping" = _: {
    programs.nixvim = {
      plugins.wrapping = {
        enable = true;
      };
    };
  };
}

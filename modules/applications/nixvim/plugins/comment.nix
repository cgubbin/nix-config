_: {
  flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-comment" = {
    programs.nixvim.plugins.comment = {
      enable = true;
      settings = {
        ignore = "^%s*$";
      };
    };
  };
}

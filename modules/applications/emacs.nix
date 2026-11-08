_: {
  flake.modules.homeManager."home-kit-global-tools-emacs" = _: {
    programs.emacs = {
      enable = true;
    };
  };
}

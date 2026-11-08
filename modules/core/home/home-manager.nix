_: {
  flake.modules.homeManager."home-kit-global-home-manager" = _: {
    home = {
      username = "kit";
      sessionVariables = {
        TERMINAL = "kitty";
        BROWSER = "firefox";
      };
    };

    nixpkgs = {
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
        # allowUnfreePredicate = pkg:
        #   builtins.elem (lib.getName pkg) [
        #     "wezterm.nvim"
        #   ];
      };
    };
    programs.home-manager.enable = true;
    home.stateVersion = "26.05";
  };
}

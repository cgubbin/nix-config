_: {
  flake.modules.homeManager."home-kit-global-tools-direnv" = _: {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableNushellIntegration = true;
    };
  };
}

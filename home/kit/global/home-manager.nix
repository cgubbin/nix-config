{
  config,
  pkgs,
  ...
}:
{
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
    };
  };
  programs.home-manager.enable = true;
  home.stateVersion = "25.05";
}

_: {
  flake.modules.homeManager."home-kit-features-cli-yazi" =
    _:
    let
      enable = true;
    in
    {
      programs.yazi = {
        inherit enable;
        shellWrapperName = "y";
        enableFishIntegration = true;
      };
    };
}

_: {
  flake.modules.homeManager."home-kit-features-cli-zoxide" =
    _:
    let
      enable = true;
    in
    {
      programs.zoxide = {
        inherit enable;
        enableFishIntegration = true;
      };
    };
}

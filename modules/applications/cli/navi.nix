_: {
  flake.modules.homeManager."home-kit-features-cli-navi" =
    _:
    let
      enable = true;
    in
    {
      programs.navi = {
        inherit enable;
      };
    };
}

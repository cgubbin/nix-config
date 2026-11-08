_: {
  flake.modules.homeManager."home-kit-features-cli-bat" =
    _:
    let
      enable = true;
    in
    {
      programs.bat = {
        inherit enable;
        config = {
          style = "numbers,changes,header";
          paging = "never";
        };
      };
    };
}

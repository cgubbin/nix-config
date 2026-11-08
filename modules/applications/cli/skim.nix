_: {
  flake.modules.homeManager."home-kit-features-cli-skim" =
    _:
    let
      enable = true;
    in
    {
      programs.skim = {
        inherit enable;
        enableFishIntegration = true;
        defaultCommand = "rg --files --hidden";
        changeDirWidgetOptions = [
          "--preview 'eza --icons --git --color always -T -L 3 {} | head -200'"
          "--exact"
        ];
      };
    };
}

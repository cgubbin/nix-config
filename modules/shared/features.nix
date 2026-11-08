{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager.shared-shells = {
    imports = [
      hm."home-kit-global-tools-fish"
      hm."home-kit-global-tools-nushell"
      hm."home-kit-global-tools-direnv"
    ];
  };
  flake.modules.homeManager.shared-cli = {
    imports = [
      hm."home-kit-features-cli-atuin"
      hm."home-kit-features-cli-bat"
      hm."home-kit-features-cli-bottom"
      hm."home-kit-features-cli-fzf"
      hm."home-kit-features-cli-tools"
      hm."home-kit-features-cli-navi"
      hm."home-kit-features-cli-skim"
      hm."home-kit-features-cli-yazi"
      hm."home-kit-features-cli-zoxide"
    ];
  };
  flake.modules.homeManager.shared-editor = {
    imports = [ hm."home-kit-global-tools-nixvim" ];
  };
}

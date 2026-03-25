{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./completion.nix
    ./keymappings.nix
    ./options.nix
    ./plugins
    ./themes.nix
  ];

  programs.nixvim = {
  	enable = true;
  	vimdiffAlias = true;
	impureRtp = true;
 };
}

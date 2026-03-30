{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.home-config.gui;
in
{
  home.packages = mkIf cfg.utils.enable (
    with pkgs;
    [
      _1password-gui
      drawio
      keymapp
      ghostty
      obsidian
      protonvpn-gui
      vlc
      zathura
      zed-editor
      zotero
    ]
  );
}

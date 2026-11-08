{ config, ... }:
let
  top = config;
in
{
  flake.modules.homeManager."home-kit-features-fonts" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib) mkIf;
      cfg = config.home-config.custom-fonts;
      dankMono = pkgs.callPackage top.flake.lib.fonts.dankMono { };
    in
    {
      #  home.packages = mkIf cfg.berkeleyMono.enable (
      #  	with pkgs;
      # [
      # 	pkgs.callPackage ./../../../home/kit/features/fonts/fonts/berkeley-mono.nix
      # ]
      #  );
      #
      home.packages = mkIf cfg.dankMono.enable (
        with pkgs;
        [
          dankMono
          font-awesome_7
        ]
      );

      #  home.packages = mkIf cfg.etBembo.enable (
      #  	with pkgs;
      # [
      # 	pkgs.callPackage ./../../../home/kit/features/fonts/fonts/et-bembo.nix
      # ]
      #  );
      #
      #  home.packages = mkIf cfg.jetBrainsMono.enable (
      #  	with pkgs;
      # [
      # 	pkgs.callPackage ./../../../home/kit/features/fonts/fonts/jetBrainsMono.nix
      # ]
      #  );
      #
      #  home.packages = mkIf cfg.symbolsMono.enable (
      #  	with pkgs;
      # [
      # 	pkgs.callPackage ./../../../home/kit/features/fonts/fonts/symbolsMono.nix
      # ]
      # );
    };
}

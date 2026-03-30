{ pkgs, ... }:
{
  imports = [
    ./options
    ./tools
    ./home-manager.nix
    (if pkgs.stdenv.isLinux then ./home-manager-linux.nix else ./home-manager-darwin.nix)
    #./sops.nix
  ];
}

{ pkgs, ... }:
{
  imports = [
    ./common.nix
    (if pkgs.stdenv.isLinux then ./linux.nix else ./darwin.nix)
  ];
}

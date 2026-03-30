{ pkgs, ... }:
{
  imports = [
    (if pkgs.stdenv.isLinux then ./linux.nix else ./darwin.nix)
  ];
}

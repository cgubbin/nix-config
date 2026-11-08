_: {
  flake.modules.homeManager."home-kit-global-home-manager-linux" =
    {
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib) mkIf;
    in
    {
      config = mkIf pkgs.stdenv.isLinux {
        home = {
          sessionVariables = {
            MOZ_ENABLE_WAYLAND = "1";
          };
        };
      };
    };
}

_: {
  flake.modules.homeManager."home-kit-features-dev-devtools-linux" =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib) mkIf;
      cfg = config.home-config.dev;
    in
    {
      services.ollama = mkIf (cfg.devTools.enable && pkgs.stdenv.isLinux) {
        enable = true;
        # acceleration = "cuda";
        package = pkgs.ollama-cpu;
      };
    };
}

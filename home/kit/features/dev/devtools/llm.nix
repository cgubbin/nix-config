{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.home-config.dev;
in {
  home.packages = mkIf cfg.devTools.enable (
    with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      claude-code
      codex
    ]
  );
}

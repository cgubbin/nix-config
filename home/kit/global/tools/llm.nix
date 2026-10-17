{
  inputs,
  pkgs,
  ...
}: {
  packages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    claude-code
    codex
  ];
}

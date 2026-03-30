{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.home-config.dev;
in
{
  # Intentionally minimal for now.
  # Add Darwin-specific devtools config here as needed.
}

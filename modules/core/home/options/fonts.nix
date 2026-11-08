_: {
  flake.modules.homeManager."home-kit-global-options-fonts" =
    {
      lib,
      config,
      ...
    }:
    let
      mkFontOption = kind: {
        family = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Family name for ${kind} font profile";
          example = "Fira Code";
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = "";
          description = "Package for ${kind} font profile";
          examples = "pkgs.fira-code";
        };
      };
      cfg = config.fontProfiles;
    in
    {
      options.fontProfiles = {
        enable = lib.mkEnableOption "Whether to enable font profiles";
        monospace = mkFontOption "monospace";
        regular = mkFontOption "regular";
      };

      config = lib.mkIf cfg.enable {
        fonts.fontconfig.enable = true;
        home.packages = [
          cfg.monospace.package
          cfg.regular.package
        ];
      };
    };
}

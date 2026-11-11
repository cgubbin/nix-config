{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager.shared-shells = {
    imports = [
      hm."home-kit-global-tools-fish"
      hm."home-kit-global-tools-nushell"
      hm."home-kit-global-tools-direnv"
    ];
  };
  flake.modules.homeManager.shared-cli = {
    imports = [
      hm."home-kit-features-cli-atuin"
      hm."home-kit-features-cli-bat"
      hm."home-kit-features-cli-bottom"
      hm."home-kit-features-cli-fzf"
      hm."home-kit-features-cli-tools"
      hm."home-kit-features-cli-navi"
      hm."home-kit-features-cli-skim"
      hm."home-kit-features-cli-yazi"
      hm."home-kit-features-cli-zoxide"
    ];
  };
  flake.modules.homeManager.shared-editor = { config, lib, ... }: {
    imports = [ hm."home-kit-global-tools-nixvim" ];
    options.sharedEditor.configDirectory = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Directory searched by the editor configuration shortcut.";
    };
    options.sharedEditor.quartoSyncPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "Optional consumer-provided quarto-sync Neovim plugin package.";
    };
    options.sharedEditor.clipboardProvider = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "wl-copy"
          "xclip"
          "xsel"
        ]
      );
      default = null;
      description = "Optional clipboard provider installed by the consumer's Nixvim package.";
    };
    options.sharedEditor.imageBackend = lib.mkOption {
      type = lib.types.enum [
        "kitty"
        "ueberzug"
        "sixel"
      ];
      default = "kitty";
      description = "Terminal image protocol used by image.nvim.";
    };
    config.programs.nixvim.globals.shared_editor_config_directory = lib.mkIf (
      config.sharedEditor.configDirectory != null
    ) config.sharedEditor.configDirectory;
    config.programs.nixvim.clipboard.providers = lib.optionalAttrs (
      config.sharedEditor.clipboardProvider != null
    ) { ${config.sharedEditor.clipboardProvider}.enable = true; };
  };
}

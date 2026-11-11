{
  inputs,
  config,
  lib,
  ...
}:
let
  hm = config.flake.modules.homeManager;
  packages = import inputs.nixpkgs { system = "x86_64-linux"; };
  consumer = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = packages;
    modules = [
      hm.shared-zellij
      {
        home.username = "consumer";
        home.homeDirectory = "/home/consumer";
        home.stateVersion = "26.05";
      }
    ];
  };
  makeInternal =
    enabled:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = packages;
      modules = [
        hm."home-kit-global-options-features"
        hm."home-kit-features-dev-zellij"
        {
          home.username = "kitsune-fixture";
          home.homeDirectory = "/home/kitsune-fixture";
          home.stateVersion = "26.05";
          home-config.dev.devTools.enable = enabled;
        }
      ];
    };
  internalEnabled = makeInternal true;
  internalDisabled = makeInternal false;
in
{
  perSystem = { pkgs, ... }: {
    checks.shared-zellij =
      let
        c = consumer.config;
        configFile = c.home.file.zellij.source;
        defaultLayout = c.xdg.configFile."zellij/layouts/default.kdl".source;
      in
      assert c.programs.zellij.enable;
      assert c.programs.zellij.enableFishIntegration == false;
      assert internalEnabled.config.programs.zellij.enable;
      assert builtins.hasAttr "zellij" internalEnabled.config.home.file;
      assert !internalDisabled.config.programs.zellij.enable;
      assert !(builtins.hasAttr "zellij" internalDisabled.config.home.file);
      pkgs.runCommand "shared-zellij-contract" { nativeBuildInputs = [ pkgs.zellij ]; } ''
        mkdir -p "$TMPDIR/home"
        export HOME="$TMPDIR/home"
        config=${configFile}
        grep -F 'theme "catppuccin-mocha"' "$config"
        grep -F 'bind "Ctrl b" { SwitchToMode "Tmux"; }' "$config"
        grep -F 'bind "e"' "$config"
        grep -F 'Run "org-capture"' "$config"
        grep -F 'Run "org-agenda"' "$config"
        grep -F 'Run "org-notes"' "$config"
        test -s ${defaultLayout}
        zellij --config "$config" setup --check > zellij-check.log
        grep -F 'CONFIG FILE]: Well defined.' zellij-check.log
        touch "$out"
      '';
  };
}

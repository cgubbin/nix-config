{
  config,
  pkgs,
  ...
}: let
  inherit (config.home-config.cli.commonTools) enable;
in {
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;

    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border"
    ];

    fileWidgetCommand = "fd --type f";
    fileWidgetOptions = [
      "--preview='bat --style=numbers --color=always {}'"
      "--preview-window=right,60%,border-left"
      "--bind=ctrl-/:toggle-preview"
      "--bind=alt-k:preview-page-up"
      "--bind=alt-j:preview-page-down"
    ];

    changeDirWidgetCommand = "fd --type d";
    changeDirWidgetOptions = [
      "--preview='eza --tree --level=2 --color=always {} | head -200'"
      "--preview-window=right,50%,border-left"
      "--bind=ctrl-/:toggle-preview"
      "--bind=alt-k:preview-page-up"
      "--bind=alt-j:preview-page-down"
    ];

    historyWidgetOptions = [
      "--layout=reverse"
      "--border"
    ];
  };

  home.packages = with pkgs; [
    fzf
    fd
    bat
    eza
  ];
}

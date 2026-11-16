_: {
  flake.modules.homeManager."home-kit-features-cli-fzf" =
    { options, ... }:
    let
      widgets = {
        file = {
          command = "fd --type f";
          options = [
            "--preview='bat --style=numbers --color=always {}'"
            "--preview-window=right,60%,border-left"
            "--bind=ctrl-/:toggle-preview"
            "--bind=alt-k:preview-page-up"
            "--bind=alt-j:preview-page-down"
          ];
        };
        changeDir = {
          command = "fd --type d";
          options = [
            "--preview='eza --tree --level=2 --color=always {} | head -200'"
            "--preview-window=right,50%,border-left"
            "--bind=ctrl-/:toggle-preview"
            "--bind=alt-k:preview-page-up"
            "--bind=alt-j:preview-page-down"
          ];
        };
        history.options = [
          "--layout=reverse"
          "--border"
        ];
      };
      # Newer Home Manager nests widget settings (fileWidget.command) and
      # warns on the flat names; stable releases only have the flat names.
      nested = options.programs.fzf ? fileWidget;
    in
    {
      programs.fzf = {
        enable = true;
        enableFishIntegration = true;

        defaultOptions = [
          "--height=40%"
          "--layout=reverse"
          "--border"
        ];
      }
      // (
        if nested then
          {
            fileWidget = widgets.file;
            changeDirWidget = widgets.changeDir;
            historyWidget = widgets.history;
          }
        else
          {
            fileWidgetCommand = widgets.file.command;
            fileWidgetOptions = widgets.file.options;
            changeDirWidgetCommand = widgets.changeDir.command;
            changeDirWidgetOptions = widgets.changeDir.options;
            historyWidgetOptions = widgets.history.options;
          }
      );
    };
}

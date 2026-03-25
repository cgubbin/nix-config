{config, ...}: let
  inherit (config.home-config.cli.commonTools) enable;
in {
  programs.atuin = {
    inherit enable;
    enableFishIntegration = true;
    settings = {
      # Search globally on ctrl-R, and locally on Up Arrow
      search_mode = "fuzzy";
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "workspace";

      # Enable repo-aware workspace behaviour when inside a git repo
      workspaces = true;

      # UI
      inline_height = 20;
      style = "compact";
      show_preview = true;
      exit_mode = "return-original";
      enter_accept = "true";

      # Sync / maintenance
      auto_sync = true;
      sync_frequency = "10m";
      update_check = false;

      # Keep noisy commands out of history
      history_filter = [
        "^ls$"
        "^cd$"
        "^exit$"
      ];

      secrets_filter = true;
      store_failed = true;
    };
  };
}

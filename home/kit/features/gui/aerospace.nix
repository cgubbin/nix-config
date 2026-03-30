{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.home-config.gui;
in
{

  programs.aerospace = mkIf cfg.utils.enable {
    enable = true;
    package = pkgs.aerospace;

    launchd = {
      enable = true;
      keepAlive = true;
    };

    settings = {
      enable-normalization-flatten-containers = false;
      enable-normalization-opposite-orientation-for-nested-containers = false;

      on-focused-monitor-changed = [
        "move-mouse monitor-lazy-center"
      ];

      workspace-to-monitor-force-assignment = {
        "1" = 1;
        "2" = [ "P27h-30" ];
        "3" = [ "LG Ultra HD" ];
      };

      mode = {
        main.binding = {
          ctrl-alt-shift-h = "focus --boundaries-action wrap-around-the-workspace left";
          ctrl-alt-shift-j = "focus --boundaries-action wrap-around-the-workspace down";
          ctrl-alt-shift-k = "focus --boundaries-action wrap-around-the-workspace up";
          ctrl-alt-shift-l = "focus --boundaries-action wrap-around-the-workspace right";

          ctrl-alt-cmd-shift-h = "move left";
          ctrl-alt-cmd-shift-j = "move down";
          ctrl-alt-cmd-shift-k = "move up";
          ctrl-alt-cmd-shift-l = "move right";

          ctrl-alt-cmd-shift-c = "split horizontal";
          ctrl-alt-cmd-shift-v = "split vertical";

          ctrl-alt-shift-f = "fullscreen";

          ctrl-alt-shift-s = "layout v_accordion";
          ctrl-alt-shift-w = "layout h_accordion";
          ctrl-alt-shift-e = "layout tiles horizontal vertical";

          ctrl-alt-cmd-shift-space = "layout floating tiling";

          ctrl-alt-shift-1 = "workspace 1";
          ctrl-alt-shift-2 = "workspace 2";
          ctrl-alt-shift-3 = "workspace 3";
          ctrl-alt-shift-4 = "workspace 4";
          ctrl-alt-shift-5 = "workspace 5";
          ctrl-alt-shift-6 = "workspace 6";
          ctrl-alt-shift-7 = "workspace 7";
          ctrl-alt-shift-8 = "workspace 8";
          ctrl-alt-shift-9 = "workspace 9";
          ctrl-alt-shift-0 = "workspace 10";

          ctrl-alt-shift-keypad1 = "workspace 1";
          ctrl-alt-shift-keypad2 = "workspace 2";
          ctrl-alt-shift-keypad3 = "workspace 3";
          ctrl-alt-shift-keypad4 = "workspace 4";
          ctrl-alt-shift-keypad5 = "workspace 5";
          ctrl-alt-shift-keypad6 = "workspace 6";
          ctrl-alt-shift-keypad7 = "workspace 7";
          ctrl-alt-shift-keypad8 = "workspace 8";
          ctrl-alt-shift-keypad9 = "workspace 9";
          ctrl-alt-shift-keypad0 = "workspace 10";

          ctrl-alt-cmd-shift-1 = "move-node-to-workspace 1";
          ctrl-alt-cmd-shift-2 = "move-node-to-workspace 2";
          ctrl-alt-cmd-shift-3 = "move-node-to-workspace 3";
          ctrl-alt-cmd-shift-4 = "move-node-to-workspace 4";
          ctrl-alt-cmd-shift-5 = "move-node-to-workspace 5";
          ctrl-alt-cmd-shift-6 = "move-node-to-workspace 6";
          ctrl-alt-cmd-shift-7 = "move-node-to-workspace 7";
          ctrl-alt-cmd-shift-8 = "move-node-to-workspace 8";
          ctrl-alt-cmd-shift-9 = "move-node-to-workspace 9";
          ctrl-alt-cmd-shift-0 = "move-node-to-workspace 10";

          ctrl-alt-cmd-shift-keypad1 = "move-node-to-workspace 1";
          ctrl-alt-cmd-shift-keypad2 = "move-node-to-workspace 2";
          ctrl-alt-cmd-shift-keypad3 = "move-node-to-workspace 3";
          ctrl-alt-cmd-shift-keypad4 = "move-node-to-workspace 4";
          ctrl-alt-cmd-shift-keypad5 = "move-node-to-workspace 5";
          ctrl-alt-cmd-shift-keypad6 = "move-node-to-workspace 6";
          ctrl-alt-cmd-shift-keypad7 = "move-node-to-workspace 7";
          ctrl-alt-cmd-shift-keypad8 = "move-node-to-workspace 8";
          ctrl-alt-cmd-shift-keypad9 = "move-node-to-workspace 9";
          ctrl-alt-cmd-shift-keypad0 = "move-node-to-workspace 10";

          ctrl-alt-cmd-shift-z = "reload-config";
          ctrl-alt-shift-r = "mode resize";
        };

        resize.binding = {
          h = "resize width -50";
          j = "resize height +50";
          k = "resize height -50";
          l = "resize width +50";
          enter = "mode main";
          esc = "mode main";
        };
      };
    };
  };
}

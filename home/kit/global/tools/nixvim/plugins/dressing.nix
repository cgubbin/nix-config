{ ... }:
{
  programs.nixvim.plugins.dressing = {
    enable = true;

    settings = {
      input = {
        enabled = true;
        default_prompt = "➤ ";
        win_options = {
          winblend = 10;
        };
      };

      select = {
        enabled = true;

        backend = [ "telescope" "builtin" ];

        telescope = {
          layout_strategy = "cursor";
          layout_config = {
            width = 0.4;
            height = 0.4;
          };
        };
      };
    };
  };
}

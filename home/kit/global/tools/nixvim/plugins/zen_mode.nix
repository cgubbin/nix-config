{ ... }:
{
    programs.nixvim = {
        plugins.zen-mode = {
            enable = true;
            settings = {
                window = {
                    width = 100;
                };
            };
        };
        keymaps = [
            {
                mode = "n";
                key = "<C-t>tz";
                action = "<cmd>ZenMode<cr>";
                options.desc = "Toggle Zen";
            }
        ];
    };
}

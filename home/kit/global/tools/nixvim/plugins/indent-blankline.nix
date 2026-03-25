{...}: {
  programs.nixvim.plugins.indent-blankline = {
    enable = true;

    settings = {
      indent = {
        char = "▏";
        tab_char = "▏";
      };

      scope = {
        enabled = true;
        show_start = false;
        show_end = false;
        injected_languages = true;
      };

      exclude = {
        filetypes = [
          "help"
          "alpha"
          "dashboard"
          "neo-tree"
          "Trouble"
          "lazy"
          "mason"
          "notify"
          "toggleterm"
          "oil"
        ];
        buftypes = [
          "terminal"
          "nofile"
          "quickfix"
          "prompt"
        ];
      };
    };
  };
}

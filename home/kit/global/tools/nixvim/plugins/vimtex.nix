{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.vimtex = {
      enable = true;
      autoLoad = false;

      settings = {
        view_method = "zathura";
        view_forward_search_on_start = false;
        imaps_enabled = 0;
        quickfix_mode = 0;
      };

      texlivePackage = pkgs.texlive.combined.scheme-medium;
      zathuraPackage = pkgs.zathura;
    };

    # opts.conceallevel = 1; # Set at the file level

    globals = {
      tex_flavor = "latex";
      tex_conceal = "abdmg";
    };
  };
}

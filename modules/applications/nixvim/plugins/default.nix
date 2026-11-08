{ config, ... }:
let
  top = config;
in
{
  flake.modules.homeManager."home-kit-global-tools-nixvim-plugins" = { ... }: {
    imports = [
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-alpha"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-comment"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-conform"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-dap"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-dressing"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-flash"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-gitsigns"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-harpoon"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-indent-blankline"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-lazy-git"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-lint"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-lsp"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-lualine"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-neo-tree"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-neotest"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-notebook"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-oil"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-overseer"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-persistence"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-rustaceanvim"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-snacks"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-surround"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-telescope"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-tmux-navigator"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-todo"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-treesitter"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-trouble"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-twilight"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-typst"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-ufo"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-undotree"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-vimtex"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-which-key"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-wrapping"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-zellij"
      top.flake.modules.homeManager."home-kit-global-tools-nixvim-plugins-zen_mode"
    ];
  };
}

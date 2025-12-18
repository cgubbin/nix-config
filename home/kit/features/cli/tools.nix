{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.home-config.cli;
in
{
  home.packages = mkIf cfg.commonTools.enable (
    with pkgs;
    [
      neofetch
      trash-cli
      dust
      ripgrep
      htop

      yq-go
      jq
      just
      eza
      fd
      fzf
      neofetch
      tree
      watch

      watchexec
      hurl

      nix-output-monitor
      noti
      killall
      wget
      tdf
      see-cat
      rsync
      master.vault-tasks
      television
      transmission_4
      restic
      todoist
      unar

      hexyl
      nasm

      # Yazi functionality
      ffmpeg-headless
      p7zip
      poppler
      resvg
      imagemagick
      xclip

      # Nix linting
      alejandra
      deadnix
      nixd
      nixfmt-rfc-style
      statix

      age
      aerc
      ast-grep
      claude-code
      grim
      hunspell
      proximity-sort
      semgrep
      shellcheck
      slurp
      treefmt
      valgrind
    ]
  );
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
  };
}

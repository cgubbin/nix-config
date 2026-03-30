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
      duf
      dysk
      ripgrep
      htop
      procs

      yq-go
      jq
      just
      eza
      fd
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
      # vault-tasks
      television
      transmission_4
      restic
      todoist
      unar

      hexyl
      nasm
      broot

      # Yazi functionality
      ffmpeg-headless
      p7zip
      poppler
      resvg
      imagemagick

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
      hunspell
      semgrep
      shellcheck
      treefmt
    ]
    ++ optionals pkgs.stdenv.isLinux [
      xclip
      grim
      slurp
      valgrind
      bandwhich
      proximity-sort
    ]
  );
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
  };
}
